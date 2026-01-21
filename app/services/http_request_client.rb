# frozen_string_literal: true

require_relative 'circuit_breaker'

class HttpRequestClient
  include HTTParty

  # Class-level circuit breaker registry (shared across all instances)
  @@circuit_breakers = {}
  @@circuit_breaker_mutex = Mutex.new

  # Configuration constants for timeout values
  DEFAULT_TIMEOUT = (ENV['HTTP_CLIENT_TIMEOUT'] || 5).to_i
  DEFAULT_OPEN_TIMEOUT = (ENV['HTTP_CLIENT_OPEN_TIMEOUT'] || 3).to_i
  DEFAULT_MAX_RETRIES = (ENV['HTTP_CLIENT_MAX_RETRIES'] || 3).to_i
  DEFAULT_RETRY_DELAY = (ENV['HTTP_CLIENT_RETRY_DELAY'] || 1).to_f

  # Circuit breaker instance per client
  attr_reader :base_url, :circuit_breaker

  def initialize(base_url, options = {})
    @base_url = base_url
    @timeout = options[:timeout] || DEFAULT_TIMEOUT
    @open_timeout = options[:open_timeout] || DEFAULT_OPEN_TIMEOUT
    @max_retries = options[:max_retries] || DEFAULT_MAX_RETRIES
    @retry_delay = options[:retry_delay] || DEFAULT_RETRY_DELAY
    @use_circuit_breaker = options.fetch(:use_circuit_breaker, true)
    @circuit_breaker_name = options[:circuit_breaker_name] || "http_client_#{base_url}"

    # Get or create shared circuit breaker
    if @use_circuit_breaker
      @circuit_breaker = get_or_create_circuit_breaker(@circuit_breaker_name)
    end
  end

  # Generic HTTP GET request
  def get(path, options = {})
    execute_request(:get, path, options)
  end

  # Generic HTTP POST request
  def post(path, options = {})
    execute_request(:post, path, options)
  end

  # Generic HTTP PUT request
  def put(path, options = {})
    execute_request(:put, path, options)
  end

  # Generic HTTP PATCH request
  def patch(path, options = {})
    execute_request(:patch, path, options)
  end

  # Generic HTTP DELETE request
  def delete(path, options = {})
    execute_request(:delete, path, options)
  end

  private

  def execute_request(method, path, options = {})
    url = build_url(path)
    request_options = build_request_options(options)

    if @use_circuit_breaker
      execute_with_circuit_breaker do
        execute_with_retry(method, url, request_options)
      end
    else
      execute_with_retry(method, url, request_options)
    end
  rescue HttpCircuitBreakerError
    # Re-raise circuit breaker errors without modification
    raise
  rescue Net::ReadTimeout, Net::OpenTimeout => e
    log_error("Timeout error for #{method.upcase} #{url}", e)
    raise HttpTimeoutError, "Request timeout: #{e.message}"
  rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
    log_error("Connection error for #{method.upcase} #{url}", e)
    raise HttpConnectionError, "Connection failed: #{e.message}"
  rescue HTTParty::Error, StandardError => e
    log_error("HTTP request error for #{method.upcase} #{url}", e)
    raise HttpRequestError, "Request failed: #{e.message}"
  end

  def execute_with_circuit_breaker(&block)
    @circuit_breaker.call(&block)
  rescue CircuitBreaker::CircuitBreakerOpenError => e
    log_error("Circuit breaker is open", e)
    raise HttpCircuitBreakerError, "Service temporarily unavailable: #{e.message}"
  end

  def execute_with_retry(method, url, options)
    retries = 0
    begin
      response = HTTParty.send(method, url, options)
      log_success(method, url, response)
      response
    rescue Net::ReadTimeout, Net::OpenTimeout, SocketError, Errno::ECONNREFUSED => e
      retries += 1
      if retries <= @max_retries
        delay = calculate_retry_delay(retries)
        Rails.logger.warn("Retry #{retries}/#{@max_retries} for #{method.upcase} #{url} after #{delay}s due to: #{e.class.name}")
        sleep(delay)
        retry
      else
        raise e
      end
    end
  end

  def build_url(path)
    return path if path.start_with?('http://', 'https://')
    URI.join(@base_url, path).to_s
  end

  def build_request_options(options)
    {
      timeout: options[:timeout] || @timeout,
      open_timeout: options[:open_timeout] || @open_timeout,
      headers: options[:headers] || {},
      body: options[:body],
      query: options[:query],
      basic_auth: options[:basic_auth],
      follow_redirects: options.fetch(:follow_redirects, true)
    }.compact
  end

  def calculate_retry_delay(retry_count)
    # Exponential backoff: base_delay * (2 ^ (retry_count - 1))
    @retry_delay * (2 ** (retry_count - 1))
  end

  def log_error(message, error)
    Rails.logger.error("#{self.class.name}: #{message} - #{error.class.name}: #{error.message}")
  end

  def log_success(method, url, response)
    Rails.logger.info("#{self.class.name}: #{method.upcase} #{url} - Status: #{response.code}")
  end

  # Custom error classes for better error handling
  class HttpTimeoutError < StandardError; end
  class HttpConnectionError < StandardError; end
  class HttpRequestError < StandardError; end
  class HttpCircuitBreakerError < StandardError; end

  def get_or_create_circuit_breaker(name)
    # Thread-safe retrieval or creation of circuit breaker
    @@circuit_breaker_mutex.synchronize do
      @@circuit_breakers[name] ||= CircuitBreaker.new(name)
    end
  end
end