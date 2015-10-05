Madloba::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { host: Rails.application.secrets.smtp_host }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address: Rails.application.secrets.smtp_address,
      :port => Rails.application.secrets.smtp_port
  }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  config.active_record.raise_in_transactional_callbacks = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  Madloba::Application.config.middleware.use ExceptionNotification::Rack,
                                             :email => {
                                                 :email_prefix => "[Madloba App error] ",
                                                 :sender_address => Rails.application.secrets.error_sender_email,
                                                 :exception_recipients => Rails.application.secrets.error_recipients_email,
                                                 :delivery_method => :smtp
                                             }
end
