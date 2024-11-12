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

Before using the API client, you must configure it using credentials obtained
from the [Incognia dashboard](https://dash.incognia.com/):

```ruby
Incognia.configure(client_id: ENV['INCOGNIA_CLIENT_ID'], client_secret: ENV['INCOGNIA_CLIENT_SECRET'])

# Incognia.configure(client_id: "your-client-id", client_secret: "your-client-secret")
```

For sandbox credentials, refer to the [API testing guide](https://developer.incognia.com/).

:bulb: For Rails applications it's recommended to create an initializer file, for example `config/initializers/incognia.rb`.


### Registering a Signup

This method registers a new signup for the given request token and address, returning a signup assessment, containing the risk assessment and supporting evidence:

```ruby
address = Incognia::Address.new(line: "West 34th Street, New York City, NY 10001")
request_token = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."

assessment = Incognia::Api.register_signup(
  request_token: request_token,
  address: address
)

# => #<OpenStruct id="...", request_id="...", device_id="...", risk_assessment="..", evidence=...>

```

It also supports optional parameters, for example:

```ruby
address = Incognia::Address.new(line: "West 34th Street, New York City, NY 10001")
request_token = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."
external_id = "7b02736a-7718-4b83-8982-f68fb6f501fa"

assessment = Incognia::Api.register_signup(
  request_token: request_token,
  address: address,
  external_id: external_id
)

# => #<OpenStruct id="...", device_id="...", risk_assessment="..", evidence=...>
```

### Registering a Login

This method registers a new login for the given request token and account, returning a login assessment, containing the risk assessment and supporting evidence:

```ruby
request_token = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."
account_id = 'account-identifier-123'

assessment = Incognia::Api.register_login(
  request_token: request_token,
  account_id: account_id,
)

# => #<OpenStruct id="...", device_id="...", risk_assessment="..", evidence=...>

```

It also supports optional parameters, for example:

```ruby
request_token = "WlMksW+jh5GPhqWBorsV8yDihoSHHpmt+DpjJ7eYxpHhuO/5tuHTuA..."
account_id = 'account-identifier-123'
external_id = 'some-external-identifier'

assessment = Incognia::Api.register_login(
  request_token: request_token,
  account_id: account_id,
  external_id: external_id,
  eval: false # can be used to register a new login without evaluating it
)

# => #<OpenStruct id="...", device_id="...", risk_assessment="..", evidence=...>
```

### Registering Payment

This method registers a new payment for the given request token and account, returning a `hash`,
containing the risk assessment and supporting evidence.

```ruby
assessment = Incognia::Api.register_payment(
  request_token: 'request-token',
  account_id: 'account-id'
)

# => #<OpenStruct id="...", device_id="...", risk_assessment="..", evidence=...>
```

It also supports optional parameters, for example:

```ruby
addresses = [
  {
    'type': 'shipping',
    'structured_address': {
      'locale': 'pt-BR',
      'country_name': 'Brasil',
      'country_code': 'BR',
      'state': 'SP',
      'city': 'São Paulo',
      'borough': '',
      'neighborhood': 'Bela Vista',
      'street': 'Av. Paulista',
      'number': '1578',
      'complements': 'Andar 2',
      'postal_code': '01310-200'
    },
    'address_coordinates': {
      'lat': -23.561414,
      'lng': -46.6558819
    }
  }
]

payment_value = {
  'amount': 5.0,
  'currency': 'BRL'
}

payment_methods = [
  {
    'type': 'credit_card',
    'credit_card_info': {
      'bin': '123456',
      'last_four_digits': '1234',
      'expiry_year': '2027',
      'expiry_month': '10'
    }
  },
  {
    'type': 'debit_card',
    'debit_card_info': {
      'bin': '123456',
      'last_four_digits': '1234',
      'expiry_year': '2027',
      'expiry_month': '10'
    }
  }
]

assessment = Incognia::Api.register_payment(
  request_token: 'request-token',
  account_id: 'account-id',
  external_id: 'external-id',
  addresses: addresses,
  payment_value: payment_value,
  payment_methods: payment_methods
)

# => #<OpenStruct id="...", device_id="...", risk_assessment="..", evidence=...>
```

### Registering a Feedback

This method registers a feedback event for the given identifiers (optional arguments), returning true when success.

The `occurred_at` argument should be a _Time_, _DateTime_ or an date in **RFC 3339** format.

The `expires_at` argument should be a _Time_, _DateTime_ or an date in **RFC 3339** format.


```ruby
request_token = 'request-token'
account_id = 'account-id'
occurred_at = DateTime.parse('2024-07-22T15:20:00Z')

success = Incognia::Api.register_feedback(
  event: Incognia::Constants::FeedbackEvent::ACCOUNT_TAKEOVER,
  occurred_at: occurred_at,
  request_token: request_token,
  account_id: account_id
)

# => true
```

For custom fraud, set the value of `event` with the corresponding code:

```ruby
success = Incognia::Api.register_feedback(
  event: 'custom_fraud_name',
  occurred_at: occurred_at,
  request_token: request_token,
  account_id: account_id
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
To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `version.rb`, run `bundle` to update the `gemfile.lock`, add one description on `CHANGELOG.md` if necessary, and then after merging on master, run `bundle exec rake release`.

The `rake release` task will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
