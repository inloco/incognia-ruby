## [Unreleased]

## [2.2.0] - 2025-09-16

- Add support for passing an optional person_id parameter to HTTP request helpers

## [2.1.0] - 2025-05-09

- Add support for passing an optional location parameter to register logins and payments

## [2.0.0] - 2024-11-12

- Remove support for instance usage of Incognia::Api
- Remove invalid feedback types
- Remove support for sending feedback timestamp

## [1.3.0] - 2024-11-12

- Add support for general configuration and use Incognia::Api as a static class

## [1.2.0] - 2024-08-26

- Removes the requirement to send installation id to register signup, login and payment

## [1.1.0] - 2024-07-24

- Add support to passing request_token and occurred_at to #register_feedback

## [1.0.0] - 2024-07-05

- Remove #get_signup_assessment, because the endpoint was discontinued

## [0.5.5] - 2024-04-01

- Fix datetime parcer to RFC3339 format

## [0.5.4] - 2024-03-19

- Allow registering feedback with expires_at parameter 

## [0.5.1] - 2023-07-13

- Allow registering payments

## [0.5.0] - 2023-04-20

- Specify dependencies version

## [0.4.0] - 2023-04-14

- Rename main filename to match the gem name

## [0.3.1] - 2023-01-24

- Allow optional params on #register_signup
- Add Reset feedback event

## [0.3.0] - 2022-05-06

- Allow registering feedbacks
- Allow registering logins

## [0.2.0] - 2022-05-06

- Allow registering signups without address

## [0.1.0] - 2021-05-28

- Initial release
