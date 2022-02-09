module DeferredRequest
  class TestController < ApplicationController
    def status_callback
      head :ok
      DeferredRequest.perform_later_from_request!(request)
    end

    def status_callback_deferred(deferred_request)
      # Do something with the deferred request
      deferred_request.params.dig("answer")
    end

    def status_error
      # don't add the "_deferred" method (used for testing)
      head :ok
      DeferredRequest.perform_later_from_request!(request)
    end
  end
end
