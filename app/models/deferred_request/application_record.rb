module DeferredRequest
  class ApplicationRecord < DeferredRequest.model_parent_class.constantize
    self.abstract_class = true
  end
end
