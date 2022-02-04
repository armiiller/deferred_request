Rails.application.routes.draw do
  mount DeferredRequest::Engine => "/deferred_request"
end
