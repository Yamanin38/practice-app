Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    # user_id を username に変更
    { username: event.payload[:username] }
  end
end