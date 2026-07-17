require "test_helper"

module DeferredRequest
  class TestControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "can_defer json request successfully" do
      answer = 1

      assert_no_performed_jobs

      assert_difference("DeferredRequest.count") do
        post status_callback_url, params: {answer: answer}, as: :json
      end

      assert_response :success

      assert_enqueued_jobs 1

      perform_enqueued_jobs

      last_request = DeferredRequest.last

      assert_equal answer, last_request.result

      assert_performed_jobs 1
    end

    test "preserves a payload key literally named 'action' through the full request cycle" do
      payload = {ticket: {id: 99}, action: {type: "TicketAction", new_status: "closed"}}

      assert_difference("DeferredRequest.count") do
        post status_callback_url, params: payload, as: :json
      end

      assert_response :success

      last_request = DeferredRequest.last
      assert_equal "status_callback", last_request.action
      assert_equal payload[:action].stringify_keys, last_request.params["action"]
      assert_equal payload[:ticket].stringify_keys, last_request.params["ticket"]
      assert_equal payload.to_json, last_request.body
    end

    test "still parses form-encoded params through the full request cycle" do
      assert_difference("DeferredRequest.count") do
        post status_callback_url, params: {answer: "42"}
      end

      assert_response :success

      last_request = DeferredRequest.last
      assert_equal "42", last_request.params["answer"]
      # NOTE: last_request.body is deliberately not asserted here - see the
      # NOTE in deferred_request_test.rb about the pre-existing, out-of-scope
      # empty-body bug for non-JSON content types.
    end

    test "can_defer json request successfully but handle no deferred method" do
      answer = 2

      assert_no_performed_jobs

      assert_difference("DeferredRequest.count") do
        post status_error_url, params: {answer: answer}, as: :json
      end

      assert_response :success

      assert_enqueued_jobs 1

      perform_enqueued_jobs

      last_request = DeferredRequest.last

      assert_not_equal answer, last_request.result
      assert_equal "error", last_request.status

      assert_performed_jobs 1
    end
  end
end
