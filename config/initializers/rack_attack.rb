# frozen_string_literal: true

class Rack::Attack
  # Allow all local traffic
  safelist('allow from localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end
  # Throttle login attempts by IP Address
  # Key: "rack::attack:PERIOD:logins/ip:IP_ADDRESS"
  throttle('api/secure/v1/alerts', limit: 10, period: 20.seconds) do |req|
    if req.path == '/api/secure/v1/alerts' && req.get?
      req.ip
    end
  end
  # Throttle API login attempts by email address
  # Key: "rack::attack:PERIOD:logins/api/email:EMAIL_ADDRESS"
  # throttle('logins/api/email', limit: 5, period: 20.seconds) do |req|
  #   if req.path == '/api/v1/sessions' && req.post?
  #     req.params['email'].to_s.downcase.strip
  #   end
  # end
end
