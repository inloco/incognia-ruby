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

### Getting a Signup

This method allows you to query the latest assessment for a given signup event, returning signup assessment, containing the risk assessment and supporting evidence:

```ruby
assessment = api.get_signup_assessment(signup_id: "95a9fc56-f65e-436b-a87f-a1338043678f")

# => #<OpenStruct id="...", request_id="...", device_id="...", risk_assessment="..", evidence=...>

```

## Exception handling

Every method call can throw `APIError` and `APIAuthenticationError`.

`APIError` is thrown when the API returned an unexpected http status code or if something goes wrong with the request (network failure, for example). You can retrieve it by calling the `status` method in the exception, along with the `errors` method, which returns the api response payload, which might include additional details. As any subclass of `StandardError` it also responds to `message`.

`APIAuthenticationError` indicates that the credentials used to authenticate were considered invalid by the API.
