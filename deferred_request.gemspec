require_relative "lib/deferred_request/version"

Gem::Specification.new do |spec|
  spec.name        = "deferred_request"
  spec.version     = DeferredRequest::VERSION
  spec.authors     = ["Austin Miller"]
  spec.email       = ["austinrmiller1991@gmail.com"]
  spec.homepage    = "https://github.com/armiiller/deferred_request"
  spec.summary     = "Deferred Request"
  spec.description = "A simple library to defer http requests until you can actually process them. (Think webhooks. Stripe webhooks, Twilio status callbacks, ect.)"
  spec.license     = "MIT"
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/armiiller/deferred_request"
  spec.metadata["changelog_uri"] = "https://github.com/armiiller/deferred_request/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 6.1"
end
