require File.expand_path('../boot', __FILE__)

require 'rails'

require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'

Bundler.require(*Rails.groups)

module Api

  class Application < Rails::Application

    config.active_record.raise_in_transactional_callbacks = true

    config.middleware.insert_before 0, 'Rack::Cors', debug: true, logger: (-> { Rails.logger }) do
      allow do
        origins '*'

        resource '/cors',
          headers: :any,
          methods: [:post],
          credentials: true,
          max_age: 0

        resource '*',
          headers: :any,
          methods: [:get, :post, :delete, :put, :options, :head],
          max_age: 0
      end
    end

  end

end
