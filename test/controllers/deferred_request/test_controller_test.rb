require "test_helper"

module DeferredRequest
  class TestControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "can_defer json request successfully" do
      answer = 1

      assert_no_enqueued_jobs

      assert_difference("DeferredRequest.count") do
        post status_callback_url, params: {answer: answer}, as: :json
      end

      assert_response :success

      assert_enqueued_jobs 1

      perform_enqueued_jobs

      last_request = DeferredRequest.last

      assert_equal answer, last_request.result

      assert_no_enqueued_jobs
    end

    test "can_defer json request successfully but handle no deferred method" do
      answer = 2

      assert_no_enqueued_jobs

      assert_difference("DeferredRequest.count") do
        post status_error_url, params: {answer: answer}, as: :json
      end

      assert_response :success

      assert_enqueued_jobs 1

      perform_enqueued_jobs

      last_request = DeferredRequest.last

      assert_not_equal answer, last_request.result
      assert_equal "error", last_request.status

      assert_no_enqueued_jobs
    end
  end
end
