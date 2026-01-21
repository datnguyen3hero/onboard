# frozen_string_literal: true

class RpcClient
  DEFAULT_TIMEOUT = 2.seconds
  MAX_RETRIES = 3

  RETRYABLE_ERRORS = [
    GRPC::Unavailable,
    GRPC::DeadlineExceeded,
    GRPC::ResourceExhausted
  ].freeze

  def initialize(stub_class, host: 'localhost:50051', max_retries: MAX_RETRIES)
    # Initialize the specific Stub (e.g., InventoryManager::Stub)
    @stub = stub_class.new(host, :this_channel_is_insecure)
    @retries = 0
    @max_retries = max_retries
  end

  # Generic execute method
  def execute(method, request, timeout: DEFAULT_TIMEOUT)
    begin
      # Calculate absolute deadline
      deadline = Time.now + timeout

      # Dynamically call the method on the stub
      @stub.public_send(method, request, deadline: deadline)

    rescue StandardError => e
      unless retries_not_exceeded?
        Rails.logger.error "Max retries exceeded for gRPC call #{method}: #{e.message}"
        raise
      end

      unless retryable_error?(e)
        Rails.logger.error "Non-retryable error for gRPC call #{method}: #{e.message}"
        raise
      end

      @retries += 1
      sleep_time = exponential_backoff_interval(@retries)
      sleep(sleep_time)
      Rails.logger.warn "Retrying gRPC call #{method}, attempt #{@retries} due to error: #{e.message}"
      retry
    end
  end

  private

  def retries_not_exceeded?
    @retries < @max_retries
  end

  def retryable_error?(error)
    # Check for specific internal errors that are retryable
    RETRYABLE_ERRORS.include?(error.class)
  end

  def exponential_backoff_interval(retry_count)
    # Base exponential backoff: 2^retry_count
    base_delay = 2**@retries
    # Add jitter: random value between 0 and (10 * (retry_count + 1))
    jitter = rand(10) * (retry_count + 1)
    base_delay + jitter
  end
end
