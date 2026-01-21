# frozen_string_literal: true

require_relative '../../lib/protos/summary_message_services_pb'
require_relative 'grpc_client'

class RankingPriorityMessageService
  def initialize(alert_message)
    @alert_message = alert_message
  end

  def get_ranking_priority
    client = RpcClient.new(Summarymessage::RakingPriorityManager::Stub)
    begin
      # Build the request object
      req = Summarymessage::RakingPriorityRequest.new(body: @alert_message)

      # Make the remote call
      @response = client.execute(:get_raking_priority, req, timeout: 3.seconds)
      Rails.logger.info "Ranking priority returned #{@response}"

      @response.priority
    rescue GRPC::BadStatus => e
      Rails.logger.error "Error getting ranking priority: #{e.message}"
      raise
    end
  end
end

