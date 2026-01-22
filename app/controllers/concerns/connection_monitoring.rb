# frozen_string_literal: true

module ConnectionMonitoring
  extend ActiveSupport::Concern

  def log_connection_stats
    pool = ActiveRecord::Base.connection_pool
    Rails.logger.info(pool.stat.to_json)
  end
end
