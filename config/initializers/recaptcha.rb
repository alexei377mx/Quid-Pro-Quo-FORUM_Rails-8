Recaptcha.configure do |config|
  config.site_key   = Rails.application.credentials.dig(:recaptcha, :site_key_v3) || "test"
  config.secret_key = Rails.application.credentials.dig(:recaptcha, :secret_key_v3) || "test"
  config.skip_verify_env << "test"
end
