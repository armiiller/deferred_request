require "deferred_request/version"
require "deferred_request/engine"

module DeferredRequest
  # Your code goes here...
  mattr_accessor :model_parent_class
  @@model_parent_class = "ActiveRecord::Base"
end
