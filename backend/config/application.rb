require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module AntecipeApi
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
    config.middleware.use Rack::Attack

    # Autoload do diretório lib/ (motor C++ wrapper, serviços, etc.)
    config.autoload_lib(ignore: %w[assets tasks])
  end
end
