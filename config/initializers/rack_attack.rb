# config/initializers/rack_attack.rb
Rack::Attack.throttle('logins/ip', limit: 5, period: 60) do |req|
  req.ip if req.path == '/login' && req.post?
end

# 追加
Rack::Attack.throttle('contacts/ip', limit: 3, period: 300) do |req|
  req.ip if req.path == '/contact' && req.post?
end

Rack::Attack.throttle('uploads/ip', limit: 10, period: 60) do |req|
  req.ip if req.path == '/images' && req.post?
end