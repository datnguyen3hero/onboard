# frozen_string_literal: true

class GetIpService
  def initialize
    @http_request_client = HttpRequestClient.new('https://dummyjson.com')
  end

  def call
    response = @http_request_client.get('/ip')
    if response.code == 200
      data = JSON.parse(response.body)
      data['ip']
    else
      Rails.logger.warn "Failed to fetch IP address: #{response.code}"
      nil
    end
  end
end
