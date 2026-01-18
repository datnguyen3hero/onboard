module AuthHelpers
  def auth_header_for(user)
    { 'Authorization' => "Bearer #{user.token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end

