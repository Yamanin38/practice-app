# config/initializers/rack_attack.rb
Rack::Attack.throttle('logins/ip', limit: 5, period: 60) do |req|
  req.ip if req.path == '/login' && req.post?
end