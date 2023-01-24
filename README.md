# Incognia Ruby Library

[![Ruby](https://github.com/inloco/incognia-ruby/actions/workflows/main.yml/badge.svg)](https://github.com/inloco/incognia-ruby/actions/workflows/main.yml)

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

This method registers a new signup for the given installation and address, returning a signup assessment, containing the risk assessment and supporting evidence:

```ruby
address = Incognia::Address.new(line: "West 34th Street, New York City, NY 10001")
installation_id = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."

assessment = api.register_signup(
  installation_id: installation_id,
  address: address
)

# => #<OpenStruct id="...", request_id="...", device_id="...", risk_assessment="..", evidence=...>

```

It also supports optional parameters, for example:

```ruby
address = Incognia::Address.new(line: "West 34th Street, New York City, NY 10001")
installation_id = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."
external_id = "7b02736a-7718-4b83-8982-f68fb6f501fa"

assessment = api.register_signup(
  installation_id: installation_id,
  address: address,
  external_id: external_id
)

# => #<OpenStruct id="...", device_id="...", risk_assessment="..", evidence=...>
```

### Getting a Signup

This method allows you to query the latest assessment for a given signup event, returning signup assessment, containing the risk assessment and supporting evidence:

```ruby
assessment = api.get_signup_assessment(signup_id: "95a9fc56-f65e-436b-a87f-a1338043678f")

# => #<OpenStruct id="...", request_id="...", device_id="...", risk_assessment="..", evidence=...>

```

### Registering a Login

This method registers a new login for the given installation and account, returning a login assessment, containing the risk assessment and supporting evidence:

```ruby
installation_id = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."
account_id = 'account-identifier-123'

assessment = api.register_login(
  installation_id: installation_id,
  account_id: account_id,
)

# => #<OpenStruct id="...", device_id="...", risk_assessment="..", evidence=...>

```

It also supports optional parameters, for example:

```ruby
installation_id = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."
account_id = 'account-identifier-123'
external_id = 'some-external-identifier'

assessment = api.register_login(
  installation_id: installation_id,
  account_id: account_id,
  external_id: external_id,
  eval: false # can be used to register a new login without evaluating it
)

# => #<OpenStruct id="...", device_id="...", risk_assessment="..", evidence=...>
```

### Registering a Feedback

This method registers a feedback event for the given identifiers (optional arguments), returning true when success.

The `timestamp` argument should be a _Time_, _DateTime_ or an _Integer_ being the timestamp in milliseconds:

```ruby
account_id = "cdb2cfbb-8ad8-4668-b276-5fff9bbfdc96"
timestamp = DateTime.parse('2022-06-20 23:29:00 UTC-3')

success = api.register_feedback(
  event: Incognia::Constants::FeedbackEvent::IDENTITY_FRAUD,
  timestamp: timestamp,
  account_id: account_id
)

# => true
```

For custom fraud, set the value of `event` with the corresponding code:

```ruby
success = api.register_feedback(
  event: 'custom_fraud_name'
  timestamp: timestamp,
  account_id: account_id,
  installation_id: installation_id
)

# => true
```

Check the [documentation](https://developer.incognia.com) to see possible identifiers for each event type.

## Exception handling

Every method call can throw `APIError` and `APIAuthenticationError`.

`APIError` is thrown when the API returned an unexpected http status code or if something goes wrong with the request (network failure, for example). You can retrieve it by calling the `status` method in the exception, along with the `errors` method, which returns the api response payload, which might include additional details. As any subclass of `StandardError` it also responds to `message`.

`APIAuthenticationError` indicates that the credentials used to authenticate were considered invalid by the API.

## How to Contribute

If you have found a bug or if you have a feature request, please report them at this repository issues section.

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
