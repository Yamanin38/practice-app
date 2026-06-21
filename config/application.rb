require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 7.1
    config.time_zone = "Tokyo"          # ← 追加
    config.active_record.default_timezone = :local  # ← 追加
    config.autoload_lib(ignore: %w(assets tasks))
    config.active_job.queue_adapter = :solid_queue
  end
end
