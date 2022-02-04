# Deferred Request
A simple plugin to defer an http request until you can actually process it. This is good in situtations where work performed is not needed immidiately (think status callbacks from services like Twilio or Stripe). This pattern can help prevent you from getting DDoS'd by services you might interact with.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "deferred_request"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install deferred_request
```

### Migrations
Copy the Deferred Request migrations to your app:

```bash
bin/rails deferred_request:install:migrations
```

Then, run the migrations:

```bash
bin/rails db:migrate
```

## Usage

### Controllers
In your controllers you can use the library like so. **Make sure you add a method with a `_deferred` suffix so that it can be processed later**

```ruby
# app/controllers/twilio.rb

# ... (snipped for brevity)
def status_callback
  # We can go ahead and give a :ok response (fast and snappy)
  head :ok

  # Then queue the request to run later
  deferred_request = DeferredRequest::DeferredRequest.from_request(request, params)
  deferred_request.save!

  deferred_request.peform_later
end

# Your deferred request method will be called later (via a job)
# deferred_request will be of type DeferredRequest::DeferredRequest
def status_callback_deferred(deferred_request)
  # do some actual processing
  if deferred_request.params["SmsStatus"] == "delivered"
    # mark message as delivered
  end

  # return a status and it will be saved to the database
  true
end
# ...
```

## 🙏 Contributing

If you have an issue you'd like to submit, please do so using the issue tracker in GitHub. In order for us to help you in the best way possible, please be as detailed as you can.

If you'd like to open a PR please make sure the following things pass:

```ruby
bin/rails db:test:prepare
bin/rails test
bundle exec standardrb
```

## 📝 License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
