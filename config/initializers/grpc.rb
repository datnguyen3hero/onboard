# frozen_string_literal: true

EhProtobuf.config_client(
  EhProtobuf::FeatureFlag,
  # host: ENV['FEATURE_FLAG_RPC_HOST'] || 'localhost',
  # port: ENV['FEATURE_FLAG_RPC_PORT'] || 50_053,
  host: 'grpc-feature-flag.staging.ehrocks.com',
  # host: 'feature-flag-api-rpc.staging.ehrocks.com',
  # host: 'feature-flag-rpc.staging',
  port: 50_051,
  logger: Rails.logger,
  # timeout: (ENV['FEATURE_FLAG_RPC_TIMEOUT'] || 2).to_i,
  timeout: (ENV['FEATURE_FLAG_RPC_TIMEOUT'] || 30).to_i,
  unavailable_retry_backoff: proc { |attempt| 2**attempt },
  # caching: {
  #   distributed_cache_config: FeatureFlagAssistant.default_distributed_caching_config.merge(
  #     error_callback: proc { |e| BugReporter.notify(e) },
  #     redis_pool_size: feature_flag_distributed_cache_redis_pool_size,
  #     )
  # },
  # client_load_balancing: feature_flag_client_lb_config
)