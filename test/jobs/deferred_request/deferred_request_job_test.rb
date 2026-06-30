require "test_helper"

module DeferredRequest
  class DeferredRequestJobTest < ActiveJob::TestCase
    test "perform processes the deferred request and stores the result" do
      deferred_request = DeferredRequest.create!(
        controller: "DeferredRequest::TestController",
        action: "status_callback",
        params: {"answer" => 21}
      )

      DeferredRequestJob.perform_now(deferred_request.id)

      deferred_request.reload
      assert_equal "complete", deferred_request.status
      assert_equal 21, deferred_request.result
    end

    test "perform does not raise when the deferred request no longer exists" do
      assert_nothing_raised do
        DeferredRequestJob.perform_now(-1)
      end
    end
  end
end
