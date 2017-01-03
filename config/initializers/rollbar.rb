if defined?(Rollbar)
  Rollbar.configure do |config|
    config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']

    # Here we'll disable in 'test':
    if Rails.env.test?
      config.enabled = false
    end

    config.environment = ENV['ROLLBAR_ENV'] || Rails.env
  end
end
