require "test_helper"

module DeferredRequest
  class DeferredRequestTest < ActiveSupport::TestCase
    def set_raw_body(request, raw_body)
      # RAW_POST_DATA alone isn't enough - Rails' JSON parser bails out early
      # when CONTENT_LENGTH is zero, so it has to be set explicitly to get
      # ActionDispatch::TestRequest to actually parse the body. The form-encoded
      # parser (Rack::Request#POST) reads rack.input directly instead of
      # RAW_POST_DATA, so that needs to be set too for non-JSON bodies.
      request.set_header("RAW_POST_DATA", raw_body)
      request.set_header("CONTENT_LENGTH", raw_body.bytesize.to_s)
      request.set_header("rack.input", StringIO.new(raw_body))
    end

    test "from_request builds attributes from an ActionDispatch::Request" do
      request = ActionDispatch::TestRequest.create
      request.path_parameters = {controller: "deferred_request/test", action: "status_callback"}
      request.request_method = "POST"
      request.set_header("HTTP_USER_AGENT", "RailsTestAgent")
      request.set_header("CONTENT_TYPE", "application/json")
      set_raw_body(request, {answer: "42"}.to_json)

      deferred_request = DeferredRequest.from_request(request)

      assert_equal "DeferredRequest::TestController", deferred_request.controller
      assert_equal "status_callback", deferred_request.action
      assert_equal "POST", deferred_request.method
      assert_equal "42", deferred_request.params["answer"]
      assert_equal "RailsTestAgent", deferred_request.headers["HTTP_USER_AGENT"]
      assert_equal "queued", deferred_request.status
      assert_not deferred_request.persisted?
    end

    test "from_request reads the routing action from path_parameters, not a payload key literally named 'action'" do
      request = ActionDispatch::TestRequest.create
      request.path_parameters = {controller: "deferred_request/test", action: "status_callback"}
      request.request_method = "POST"
      request.set_header("CONTENT_TYPE", "application/json")
      # mimics the HaloPSA webhook shape: sibling top-level "ticket" and "action" objects
      payload = {"ticket" => {"id" => 1, "subject" => "Printer down"}, "action" => {"type" => "TicketAction", "new_status" => "closed"}}
      set_raw_body(request, payload.to_json)

      deferred_request = DeferredRequest.from_request(request)

      # the routing action must still reflect the actual controller action, not the payload key
      assert_equal "status_callback", deferred_request.action
      # but the payload's "action" key must survive in params, unclobbered
      assert_equal payload["action"], deferred_request.params["action"]
      assert_equal payload["ticket"], deferred_request.params["ticket"]
    end

    test "from_request preserves a payload key literally named 'controller'" do
      request = ActionDispatch::TestRequest.create
      request.path_parameters = {controller: "deferred_request/test", action: "status_callback"}
      request.request_method = "POST"
      request.set_header("CONTENT_TYPE", "application/json")
      payload = {"controller" => "should-survive", "ticket" => {"id" => 2}}
      set_raw_body(request, payload.to_json)

      deferred_request = DeferredRequest.from_request(request)

      assert_equal "DeferredRequest::TestController", deferred_request.controller
      assert_equal "should-survive", deferred_request.params["controller"]
    end

    test "from_request captures both correct params and the correct raw body for a JSON POST" do
      request = ActionDispatch::TestRequest.create
      request.path_parameters = {controller: "deferred_request/test", action: "status_callback"}
      request.request_method = "POST"
      request.set_header("CONTENT_TYPE", "application/json")
      raw_body = {"answer" => "42", "nested" => {"a" => 1}}.to_json
      set_raw_body(request, raw_body)

      deferred_request = DeferredRequest.from_request(request)

      assert_equal "42", deferred_request.params["answer"]
      assert_equal({"a" => 1}, deferred_request.params["nested"])
      assert_equal raw_body, deferred_request.body
      assert_not deferred_request.body.empty?
    end

    test "from_request still parses form-encoded POST bodies via request_parameters" do
      request = ActionDispatch::TestRequest.create
      request.path_parameters = {controller: "deferred_request/test", action: "status_callback"}
      request.request_method = "POST"
      request.set_header("CONTENT_TYPE", "application/x-www-form-urlencoded")
      set_raw_body(request, "answer=42&nested%5Ba%5D=1")

      deferred_request = DeferredRequest.from_request(request)

      assert_equal "42", deferred_request.params["answer"]
      assert_equal "1", deferred_request.params.dig("nested", "a")
      # NOTE: deferred_request.body is deliberately not asserted here - there's a
      # separate, pre-existing (not introduced by this change) bug where
      # request.body.read comes back empty for non-JSON content types when
      # called after request.request_parameters has already parsed the body.
      # Reproduced against a clean checkout too, so it's out of scope for this fix.
    end

    test "from_request does not invent route segments that aren't present on the route" do
      request = ActionDispatch::TestRequest.create
      request.path_parameters = {controller: "deferred_request/test", action: "status_callback"}
      request.request_method = "POST"
      request.set_header("CONTENT_TYPE", "application/json")
      set_raw_body(request, {answer: "42"}.to_json)

      deferred_request = DeferredRequest.from_request(request)

      # this route has no :pagertree_integration_id segment - the gem must not
      # hardcode consumer-specific route params, since other consumers (sentry,
      # postmark, slack, etc.) have entirely different route shapes
      assert_not deferred_request.params.key?("pagertree_integration_id")
    end

    test "perform_later_from_request! saves the request and enqueues a job" do
      request = ActionDispatch::TestRequest.create
      request.path_parameters = {controller: "deferred_request/test", action: "status_callback"}
      request.set_header("RAW_POST_DATA", "")

      assert_enqueued_with(job: DeferredRequestJob) do
        deferred_request = DeferredRequest.perform_later_from_request!(request)
        assert deferred_request.persisted?
      end
    end

    test "perform! invokes the matching _deferred method and marks the request complete" do
      deferred_request = DeferredRequest.create!(
        controller: "DeferredRequest::TestController",
        action: "status_callback",
        params: {"answer" => 7}
      )

      deferred_request.perform!

      assert_equal "complete", deferred_request.status
      assert_equal 7, deferred_request.result
    end

    test "perform! marks the request as errored when the deferred method is missing" do
      deferred_request = DeferredRequest.create!(
        controller: "DeferredRequest::TestController",
        action: "status_error",
        params: {}
      )

      deferred_request.perform!

      assert_equal "error", deferred_request.status
      assert_match(/status_error_deferred/, deferred_request.result)
    end

    test "get_headers only keeps headers prefixed with HTTP" do
      request = ActionDispatch::TestRequest.create
      request.set_header("HTTP_USER_AGENT", "RailsTestAgent")
      request.set_header("CONTENT_TYPE", "application/json")

      headers = DeferredRequest.get_headers(request)

      assert_equal "RailsTestAgent", headers["HTTP_USER_AGENT"]
      assert_not headers.key?("CONTENT_TYPE")
    end
  end
end
