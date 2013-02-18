Weeverails::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!
	config.time_zone = 'Pacific Time (US & Canada)'

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
	config.assets.compile = true

	config.action_mailer.delivery_method = :smtp
	config.action_mailer.smtp_settings = {
		:address              => "smtp.gmail.com",
		:port                 => 587,
		:domain               => 'baci.lindsaar.net',
		:user_name            => 'hello@weeve.it',
		:password             => 'weevechange',
		:authentication       => 'plain',
		:enable_starttls_auto => true  }

	config.d_email = 'hello@weeve.it'
	config.domain = 'http://weeve.it'

	config.assets.paths << "#{Rails.root}/app/assets/fonts"

	#change these to contain production credetials
	config.paypal_login = "hello_api1.weeve.it"
	config.paypal_password = "LDH4HDTENHFDE54B"
	config.paypal_apikey = "AbNdd4r6vjRYxhxSZoG6SKG0kXunAMZUsVPzVpZujxLoT57Q87ljTTHl"
	config.app_id = "APP-51F55478LS296344Y"
	config.weeve_paypal_email = 'hello@weeve.it'
end

#change this to development mode
ActiveMerchant::Billing::Base.mode = :production
