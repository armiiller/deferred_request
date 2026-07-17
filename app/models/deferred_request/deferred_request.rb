module DeferredRequest
  class DeferredRequest < DeferredRequest.model_parent_class.constantize
    serialize :routing, coder: JSON
    serialize :request, coder: JSON
    serialize :result, coder: JSON

    store_accessor :routing, "controller", "action"
    store_accessor :request, "url", "method", "headers", "params", "remote_ip", "body"

    enum :status, {queued: 0, processing: 1, complete: 2, error: 99}

    # request: ActionDispatch::Request
    # create a deferred request from a ActionDispatch::Request
    def self.from_request(request)
      deferred_request = ::DeferredRequest.deferred_request_instance_class.constantize.new

      deferred_request.controller = request.controller_class.name
      # use path_parameters, not request.params, for the routing action -
      # request.params may contain a payload key literally called "action"
      # (e.g. HaloPSA webhooks) and we don't want that ambiguity here
      deferred_request.action = request.path_parameters[:action]

      deferred_request.url = request.url
      deferred_request.method = request.method
      deferred_request.headers = get_headers(request)

      # request_parameters (body) + query_parameters only - deliberately
      # excludes path_parameters(:controller, :action) so a payload key
      # literally named "action" or "controller" isn't clobbered by Rails'
      # routing metadata. We then re-merge back in the *other* route segments
      # (e.g. :pagertree_integration_id) applied last, so they win over any
      # colliding payload/query key of the same name. This gem is shared
      # across many controllers with different route shapes, so this can't
      # hardcode one consumer's route param name.
      deferred_request.params = request.request_parameters
        .merge(request.query_parameters)
        .merge(request.path_parameters.except(:controller, :action))
        .with_indifferent_access

      deferred_request.body = request.body.read
      deferred_request.remote_ip = request.remote_ip

      deferred_request
    end

    def self.perform_later_from_request!(request)
      deferred_request = DeferredRequest.from_request(request)
      deferred_request.save!

      deferred_request.perform_later

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

        self.result = klass.send(:"#{action}_deferred", self)
        self.status = :complete
      rescue => e
        Rails.logger.error("DeferredRequest::DeferredRequestJob: #{e.message}")
        self.result = e.message
        self.status = :error
      end

      save!
    end

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
