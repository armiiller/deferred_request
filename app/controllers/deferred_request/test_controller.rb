module DeferredRequest
  class TestController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def status_callback
      # We can go ahead and give a :ok response (fast and snappy)
      head :ok

      # Then queue the request to run later
      deferred_request = DeferredRequest::DeferredRequest.from_request(request, params)
      deferred_request.save!

      deferred_request.peform_later
    end

    def status_callback_deferred(deferred_request)
      # do some actual processing
      if deferred_request.params["SmsStatus"] == "delivered"
        # mark message as delivered
      end
    
      # return a status and it will be saved to the database
      true
    end
  end
end
