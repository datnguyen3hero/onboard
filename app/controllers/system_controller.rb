# frozen_string_literal: true

class SystemController < ApplicationController
  # skip_before_action :authenticate!, only: [:health, :stats]

  def health
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      process_id: Process.pid,
      thread_count: Thread.list.size
    }
  end

  def stats
    pool = ActiveRecord::Base.connection_pool
    render json: {
      database: pool.stat,
      puma: puma_stats,
      system: system_stats,
      sidekiq: check_sidekiq
    }
  end

  private

  def puma_stats
    if defined?(Puma)
      {
        workers: ENV.fetch('WEB_CONCURRENCY', 1).to_i,
        threads_min: ENV.fetch('RAILS_MIN_THREADS', 5).to_i,
        threads_max: ENV.fetch('RAILS_MAX_THREADS', 5).to_i
      }
    else
      { message: 'Puma not detected' }
    end
  end

  def system_stats
    {
      ruby_version: RUBY_VERSION,
      rails_version: Rails.version,
      memory_usage: `ps -o rss= -p #{Process.pid}`.to_i * 1024, # Convert to bytes
      disk: check_disk_space
    }
  rescue StandardError => e
    { error: 'Unable to collect system stats' }
  end

  def check_sidekiq
    stats = Sidekiq::Stats.new
    {
      status: stats.failed < 100 ? 'ok' : 'warning',
      processed: stats.processed,
      failed: stats.failed,
      busy: stats.workers_size,
      enqueued: stats.enqueued
    }
  rescue => e
    { status: 'error', error: e.message }
  end

  def check_disk_space
    disk_info = `df -h /`.split("\n").last.split
    usage_percent = disk_info[4].to_i
    {
      status: usage_percent < 85 ? 'ok' : 'warning',
      usage_percent: usage_percent,
      available: disk_info[3]
    }
  end
end
