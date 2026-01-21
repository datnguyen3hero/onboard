# frozen_string_literal: true

module ConnectionMonitoring
  extend ActiveSupport::Concern

  def log_connection_stats
    pool = ActiveRecord::Base.connection_pool
    Rails.logger.info({
      pool_size: pool.size,
      checked_out_connections: pool.checked_out.size,
      available_connections: pool.available_count,
      queue_length: pool.num_waiting_in_queue
    }.to_json)
  end
end
