# frozen_string_literal: true

require_relative '../../lib/protos/summary_message_services_pb'

class SummaryMessageService
  def initialize(alert_message)
    @alert_message = alert_message
  end

  def generate_summary
    # Establish connection to the gRPC server (App 1)
    # Note: Port 50051 matches the port defined in the server's rake task
    stub = Summarymessage::SummaryMessageManager::Stub.new('localhost:50051', :this_channel_is_insecure)
    begin
      # Build the request object
      req = Summarymessage::AlertMessageRequest.new(body: @alert_message)

      # Make the remote call
      @response = stub.get_summary(req)
      Rails.logger.info "Alert summary returned #{@response}"

      @response.summary
    rescue GRPC::BadStatus => e
      Rails.logger.error "Error getting alert summary: #{e.message}"
      raise
    end
  end
end

