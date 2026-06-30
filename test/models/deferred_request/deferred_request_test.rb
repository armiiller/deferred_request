require "test_helper"

module DeferredRequest
  class DeferredRequestTest < ActiveSupport::TestCase
    test "from_request builds attributes from an ActionDispatch::Request" do
      request = ActionDispatch::TestRequest.create
      request.path_parameters = {controller: "deferred_request/test", action: "status_callback"}
      request.request_method = "POST"
      request.set_header("HTTP_USER_AGENT", "RailsTestAgent")
      request.set_header("RAW_POST_DATA", "")
      request.params["answer"] = "42"

      deferred_request = DeferredRequest.from_request(request)

      assert_equal "DeferredRequest::TestController", deferred_request.controller
      assert_equal "status_callback", deferred_request.action
      assert_equal "POST", deferred_request.method
      assert_equal "42", deferred_request.params["answer"]
      assert_equal "RailsTestAgent", deferred_request.headers["HTTP_USER_AGENT"]
      assert_equal "queued", deferred_request.status
      assert_not deferred_request.persisted?
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
