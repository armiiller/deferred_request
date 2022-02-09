DeferredRequest::Engine.routes.draw do
  post "status_callback" => "test#status_callback"
  post "status_error" => "test#status_error"
end
