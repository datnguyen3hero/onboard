# frozen_string_literal: true

require_relative '../../lib/protos/summary_message_services_pb'
require_relative 'grpc_client'
require_relative 'circuit_breaker'

class SummaryMessageService

  # Using a class-level circuit breaker to share state across instances
  @@circuit_breaker = CircuitBreaker.new(:summary_message_service_circuit_breaker)

  def initialize(alert_message)
    @alert_message = alert_message
  end

  def generate_summary
    client = RpcClient.new(Summarymessage::SummaryMessageManager::Stub)
    begin
      # Build the request object
      req = Summarymessage::AlertMessageRequest.new(body: @alert_message)

      # Make the remote call
      @response = execute_with_circuit_breaker { client.execute(:get_summary, req, timeout: 3.seconds) }
      Rails.logger.info "Alert summary returned #{@response}"

      @response.summary
    rescue GRPC::BadStatus => e
      Rails.logger.error "Error getting alert summary: #{e.message}"
      raise e
    end
  end

  private

  def execute_with_circuit_breaker(&block)
    @@circuit_breaker.call do
      block.call
    end
  rescue StandardError => e
    if e.instance_of?(CircuitBreaker::CircuitBreakerOpenError)
      Rails.logger.error "Circuit breaker is open for gRPC call: #{e.message}"
      raise e
    end
    raise e
  end
end

