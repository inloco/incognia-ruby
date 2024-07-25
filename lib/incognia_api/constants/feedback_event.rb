module Incognia
  module Constants
    module FeedbackEvent
      ACCOUNT_ALLOWED = 'account_allowed'.freeze
      ACCOUNT_TAKEOVER = 'account_takeover'.freeze
      CHARGEBACK = 'chargeback'.freeze
      CHARGEBACK_NOTIFICATION = 'chargeback_notification'.freeze
      PROMOTION_ABUSE = 'promotion_abuse'.freeze
      DEVICE_ALLOWED = 'device_allowed'.freeze
      IDENTITY_FRAUD = 'identity_fraud'.freeze
      RESET = 'reset'.freeze
      VERIFIED = 'verified'.freeze

      SIGNUP_ACCEPTED = 'signup_accepted'.freeze
      SIGNUP_DECLINED = 'signup_declined'.freeze

      LOGIN_ACCEPTED = 'login_accepted'.freeze
      LOGIN_ACCEPTED_BY_DEVICE_VERIFICATION = 'login_accepted_by_device_verification'.freeze
      LOGIN_ACCEPTED_BY_FACIAL_BIOMETRICS = 'login_accepted_by_facial_biometrics'.freeze
      LOGIN_ACCEPTED_BY_MANUAL_REVIEW = 'login_accepted_by_manual_review'.freeze
      LOGIN_DECLINED = 'login_declined'.freeze
      LOGIN_DECLINED_BY_FACIAL_BIOMETRICS = 'login_declined_by_facial_biometrics'.freeze
      LOGIN_DECLINED_BY_MANUAL_REVIEW = 'login_declined_by_manual_review'.freeze

      PAYMENT_ACCEPTED = 'payment_accepted'.freeze
      PAYMENT_ACCEPTED_BY_CONTROL_GROUP = 'payment_accepted_by_control_group'.freeze
      PAYMENT_ACCEPTED_BY_THIRD_PARTY = 'payment_accepted_by_third_party'.freeze
      PAYMENT_DECLINED = 'payment_declined'.freeze
      PAYMENT_DECLINED_BY_ACQUIRER = 'payment_declined_by_acquirer'.freeze
      PAYMENT_DECLINED_BY_BUSINESS = 'payment_declined_by_business'.freeze
      PAYMENT_DECLINED_BY_MANUAL_REVIEW = 'payment_declined_by_manual_review'.freeze
      PAYMENT_DECLINED_BY_RISK_ANALYSIS = 'payment_declined_by_risk_analysis'.freeze
    end
  end
end
