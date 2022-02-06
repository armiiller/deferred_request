module DeferredRequest
  class DeferredRequestJob < ApplicationJob
    queue_as :default

    def perform(*args)
      id = args[0]
      request = DeferredRequest.find(id)
      request.perform!
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error("DeferredRequest::DeferredRequestJob: Could not find DeferredRequest with id: #{id}")
    end
  end
end
