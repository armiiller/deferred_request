module DeferredRequest
  class DeferredRequest < ApplicationRecord
    serialize :routing, JSON, default: {}
    serialize :request, JSON, default: {}

    store_accessor :routing, "controller", "action"
    store_accessor :request, "url", "method", "headers", "params", "remote_ip"

    enum status: {queued: 0, processing: 1, complete: 2, error: 99}

    # request: ActionDispatch::Request
    # create a deferred request from a ActionDispatch::Request
    def self.from_request(request)
      deferred_request = DeferredRequest.new

      debugger
      deferred_request.controller = request.controller_class
      deferred_request.action = request.params["action"]

      deferred_request.url = request.url
      deferred_request.method = request.method
      deferred_request.headers = get_headers(request)
      deferred_request.params = request.params.except(:controller, :action)
      deferred_request.remote_ip = request.remote_ip

      deferred_request
    end

    def perform_later
      DeferredRequestJob.perform_later(id)
    end

    def perform!
      begin
        self.status = :processing
        save!

        klass = controller.constantize.new

        self.result = klass.try("#{action}_deferred".to_sym, self)
        self.status = :complete
      rescue => e
        Rails.logger.error("DeferredRequest::DeferredRequestJob: #{e.message}")
        self.result = e.message
        self.status = :error
      end

      save!
    end

    private

    def self.get_headers(request)
      # Get the request headers from the request
      {}.tap do |t|
        request.headers.each do |key, value|
          t[key] = value if key.downcase.starts_with?("http")
        end
      end
    end
  end
end
