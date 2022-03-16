# Incognia Ruby Library

Incognia Ruby library provides easy access to the Incogia API from Ruby
applications. It includes:

- Basic Access Token management (with transparent token refresh)
- API resounces dinamically built from API responses

For more information on how to integrate Incognia APIs, refer to one of the
following guides:

- Address verification on user onboarding
- Protecting app logins
- Secure and frictionless device change

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'incognia_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install incognia_api

## Usage

### Configuration

Before using the API client, you must initialize it using credentials obtained
from the [Incognia dashboard]():

```ruby
api = Incognia::Api.new(client_id: "your-client-id", client_secret:
"your-client-secret")

```

For sandbox credentials, refer to the [API testing guide]().


### Registering a Signup

```ruby
address = Incognia::Address.new(line: "West 34th Street, New York City, NY 10001")
installation_id = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."

response = api.register_signup(
  installation_id: installation_id,
  address: a
)

# => #<OpenStruct id="...", request_id="...", device_id="...", risk_assessment="..", evidence=...>

```
