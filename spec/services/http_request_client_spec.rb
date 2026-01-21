# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HttpRequestClient, type: :service do
  let(:base_url) { 'https://api.example.com' }
  let(:client) { described_class.new(base_url) }
  let(:path) { '/users' }
  let(:full_url) { "#{base_url}#{path}" }

  describe '#initialize' do
    it 'sets the base_url' do
      expect(client.base_url).to eq(base_url)
    end

    it 'uses default timeout values' do
      expect(client.instance_variable_get(:@timeout)).to eq(5)
      expect(client.instance_variable_get(:@open_timeout)).to eq(3)
    end

    it 'accepts custom timeout values' do
      custom_client = described_class.new(base_url, timeout: 10, open_timeout: 5)
      expect(custom_client.instance_variable_get(:@timeout)).to eq(10)
      expect(custom_client.instance_variable_get(:@open_timeout)).to eq(5)
    end

    it 'initializes circuit breaker by default' do
      expect(client.circuit_breaker).to be_a(CircuitBreaker)
    end

    it 'can disable circuit breaker' do
      no_cb_client = described_class.new(base_url, use_circuit_breaker: false)
      expect(no_cb_client.circuit_breaker).to be_nil
    end

    it 'accepts custom retry configuration' do
      custom_client = described_class.new(base_url, max_retries: 5, retry_delay: 2.0)
      expect(custom_client.instance_variable_get(:@max_retries)).to eq(5)
      expect(custom_client.instance_variable_get(:@retry_delay)).to eq(2.0)
    end
  end

  describe '#get' do
    let(:response) { double('response', code: 200, body: '{"data": "test"}') }

    it 'executes GET request successfully' do
      expect(HTTParty).to receive(:get).with(
        full_url,
        hash_including(timeout: 5, open_timeout: 3)
      ).and_return(response)

      result = client.get(path)
      expect(result).to eq(response)
    end

    it 'passes custom headers' do
      headers = { 'Authorization' => 'Bearer token' }
      expect(HTTParty).to receive(:get).with(
        full_url,
        hash_including(headers: headers)
      ).and_return(response)

      client.get(path, headers: headers)
    end

    it 'passes query parameters' do
      query = { page: 1, limit: 10 }
      expect(HTTParty).to receive(:get).with(
        full_url,
        hash_including(query: query)
      ).and_return(response)

      client.get(path, query: query)
    end
  end

  describe '#post' do
    let(:response) { double('response', code: 201, body: '{"id": 1}') }
    let(:body) { { name: 'Test User' } }

    it 'executes POST request successfully' do
      expect(HTTParty).to receive(:post).with(
        full_url,
        hash_including(body: body, timeout: 5)
      ).and_return(response)

      result = client.post(path, body: body)
      expect(result).to eq(response)
    end
  end

  describe '#put' do
    let(:response) { double('response', code: 200, body: '{"updated": true}') }

    it 'executes PUT request successfully' do
      expect(HTTParty).to receive(:put).with(
        full_url,
        hash_including(timeout: 5)
      ).and_return(response)

      result = client.put(path)
      expect(result).to eq(response)
    end
  end

  describe '#patch' do
    let(:response) { double('response', code: 200, body: '{"updated": true}') }

    it 'executes PATCH request successfully' do
      expect(HTTParty).to receive(:patch).with(
        full_url,
        hash_including(timeout: 5)
      ).and_return(response)

      result = client.patch(path)
      expect(result).to eq(response)
    end
  end

  describe '#delete' do
    let(:response) { double('response', code: 204, body: '') }

    it 'executes DELETE request successfully' do
      expect(HTTParty).to receive(:delete).with(
        full_url,
        hash_including(timeout: 5)
      ).and_return(response)

      result = client.delete(path)
      expect(result).to eq(response)
    end
  end

  describe 'retry mechanism' do
    let(:response) { double('response', code: 200, body: 'success') }
    let(:retry_client) { described_class.new(base_url, max_retries: 3, retry_delay: 0.1) }

    it 'retries on timeout errors' do
      call_count = 0
      allow(HTTParty).to receive(:get) do
        call_count += 1
        raise Net::ReadTimeout if call_count < 3
        response
      end

      expect(Rails.logger).to receive(:warn).twice
      result = retry_client.get(path)
      expect(result).to eq(response)
      expect(call_count).to eq(3)
    end

    it 'uses exponential backoff' do
      allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)

      expect(retry_client).to receive(:sleep).with(0.1).ordered
      expect(retry_client).to receive(:sleep).with(0.2).ordered
      expect(retry_client).to receive(:sleep).with(0.4).ordered

      expect { retry_client.get(path) }.to raise_error(HttpRequestClient::HttpTimeoutError)
    end

    it 'raises error after max retries' do
      allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)

      expect { retry_client.get(path) }.to raise_error(HttpRequestClient::HttpTimeoutError)
    end
  end

  describe 'circuit breaker integration' do
    let(:response) { double('response', code: 200) }

    it 'uses circuit breaker when enabled' do
      expect(client.circuit_breaker).to receive(:call).and_yield
      expect(HTTParty).to receive(:get).and_return(response)

      client.get(path)
    end

    it 'skips circuit breaker when disabled' do
      no_cb_client = described_class.new(base_url, use_circuit_breaker: false)
      expect(HTTParty).to receive(:get).and_return(response)

      no_cb_client.get(path)
    end

    it 'raises HttpCircuitBreakerError when circuit is open' do
      allow(client.circuit_breaker).to receive(:call).and_raise(
        CircuitBreaker::CircuitBreakerOpenError.new('Circuit open')
      )

      expect { client.get(path) }.to raise_error(HttpRequestClient::HttpCircuitBreakerError)
    end
  end

  describe 'error handling' do
    it 'raises HttpTimeoutError on Net::ReadTimeout' do
      allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)

      expect { client.get(path) }.to raise_error(HttpRequestClient::HttpTimeoutError, /Request timeout/)
    end

    it 'raises HttpTimeoutError on Net::OpenTimeout' do
      allow(HTTParty).to receive(:get).and_raise(Net::OpenTimeout)

      expect { client.get(path) }.to raise_error(HttpRequestClient::HttpTimeoutError, /Request timeout/)
    end

    it 'raises HttpConnectionError on SocketError' do
      allow(HTTParty).to receive(:get).and_raise(SocketError)

      expect { client.get(path) }.to raise_error(HttpRequestClient::HttpConnectionError, /Connection failed/)
    end

    it 'raises HttpConnectionError on ECONNREFUSED' do
      allow(HTTParty).to receive(:get).and_raise(Errno::ECONNREFUSED)

      expect { client.get(path) }.to raise_error(HttpRequestClient::HttpConnectionError, /Connection failed/)
    end

    it 'raises HttpRequestError on general errors' do
      allow(HTTParty).to receive(:get).and_raise(StandardError.new('Unknown error'))

      expect { client.get(path) }.to raise_error(HttpRequestClient::HttpRequestError, /Request failed/)
    end
  end

  describe 'URL building' do
    it 'joins base_url with relative path' do
      expect(HTTParty).to receive(:get).with(
        full_url,
        anything
      ).and_return(double(code: 200))

      client.get(path)
    end

    it 'uses absolute URL as-is' do
      absolute_url = 'https://other-api.com/endpoint'
      expect(HTTParty).to receive(:get).with(
        absolute_url,
        anything
      ).and_return(double(code: 200))

      client.get(absolute_url)
    end
  end

  describe 'logging' do
    let(:response) { double('response', code: 200) }

    it 'logs successful requests' do
      allow(HTTParty).to receive(:get).and_return(response)
      expect(Rails.logger).to receive(:info).with(/GET #{full_url} - Status: 200/)

      client.get(path)
    end

    it 'logs errors' do
      allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)
      expect(Rails.logger).to receive(:error).with(/Timeout error/)

      expect { client.get(path) }.to raise_error(HttpRequestClient::HttpTimeoutError)
    end
  end

  describe 'authentication' do
    let(:response) { double('response', code: 200) }
    let(:basic_auth) { { username: 'user', password: 'pass' } }

    it 'supports basic authentication' do
      expect(HTTParty).to receive(:get).with(
        full_url,
        hash_including(basic_auth: basic_auth)
      ).and_return(response)

      client.get(path, basic_auth: basic_auth)
    end
  end
end
