# frozen_string_literal: true

class CircuitBreaker
  FAILURE_THRESHOLD = 5      # Number of failures before opening circuit
  TIMEOUT_SECONDS = 60       # How long to keep circuit open
  SUCCESS_THRESHOLD = 3      # Successful calls needed to close circuit

  # FAILURE_THRESHOLD = 3      # Number of failures before opening circuit
  # TIMEOUT_SECONDS = 120       # How long to keep circuit open
  # SUCCESS_THRESHOLD = 2      # Successful calls needed to close circuit

  def initialize(name)
    @name = name
    @failure_count = 0
    @last_failure_time = nil
    @state = :closed        # :closed, :open, :half_open
    @success_count = 0
  end

  def call(&block)
    case @state
    when :closed
      execute_call(&block)
    when :open
      if circuit_should_attempt_reset?
        @state = :half_open
        @success_count = 0
        Rails.logger.info("Circuit breaker #{@name} attempting reset")
        execute_call(&block)
      else
        raise CircuitBreakerOpenError, "Circuit breaker #{@name} is open"
      end
    when :half_open
      execute_call(&block)
    end
  end
  private
  def execute_call(&block)
    begin
      result = block.call
      handle_success
      result
    rescue StandardError => e
      handle_failure(e)
      raise e
    end
  end

  def handle_success
    case @state
    when :closed
      @failure_count = 0
    when :half_open
      @success_count += 1
      if @success_count >= SUCCESS_THRESHOLD
        @state = :closed
        @failure_count = 0
        Rails.logger.info("Circuit breaker #{@name} closed")
      end
    end
  end

  def handle_failure(error)
    @failure_count += 1
    @last_failure_time = Time.current
    if @failure_count >= FAILURE_THRESHOLD
      @state = :open
      Rails.logger.error("Circuit breaker #{@name} opened due to failures")
    end
  end

  def circuit_should_attempt_reset?
    Time.current - @last_failure_time > TIMEOUT_SECONDS
  end

  class CircuitBreakerOpenError < StandardError; end
end
