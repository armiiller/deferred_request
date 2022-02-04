module DeferredRequest
  class DeferredRequest < ApplicationRecord
    serialize :routing, JSON, default: {}
    serialize :request, JSON, default: {}

    store_accessor :routing, :controller, :action
    store_accessor :request, :url, :method, :headers, :params, :remote_ip

    enum status: {queued: 0, processing: 1, processed: 2, failed: 99}

    # request: ActionDispatch::Request
    # params: ActionDispatch::Http::Parameters
    # create a deferred request from a ActionDispatch::Request and ActionDispatch::Http::Parameters
    def self.from_request(request, params)
      deferred_request = DeferredRequest::DeferredRequest.new

      deferred_request.controller = params["controller"]
      deferred_request.action = params["action"]
      
      deferred_request.url = request.url
      deferred_request.method = request.method
      deferred_request.headers = get_headers(request)
      deferred_request.params = params.to_unsafe_h.except(:controller, :action)
      deferred_request.remote_ip = request.remote_ip

      deferred_request
    end

    def perform_later
      DeferredRequest::DeferredRequestJob.perform_later(self.id)
    end

    def perform!
      begin
        self.status = :processing
        self.save!

        klass = request.klass
        method = request.method

        self.result = klass.try(method.to_sym, request.params)

        self.status = :complete
      rescue => exception
        Rails.logger.error("DeferredRequest::DeferredRequestJob: #{e.message}")
        self.result = e.message
        self.status = :error
      end
      
      self.save!
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
