DeferredRequest::Engine.routes.draw do
  post "status_callback" => "deferred_request/test#status_callback"
end
