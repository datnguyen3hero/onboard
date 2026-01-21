# frozen_string_literal: true

class BaseWorker
  include Sidekiq::Worker
  include Sidekiq::Batch if defined?(Sidekiq::Batch)
  # Default configuration
  sidekiq_options queue: :default, retry: 3, backtrace: true
  # Structured logging
  def self.perform_async_with_logging(*args)
    job_id = perform_async(*args)
    Rails.logger.info(
      message: "Job enqueued",
      job_class: self.name,
      job_id: job_id,
      args: args.inspect
    )
    job_id
  end

  def perform(*args)
    Rails.logger.info(
      message: "Job started",
      job_class: self.class.name,
      args: args.inspect
    )
    start_time = Time.current
    begin
      call(*args)
      Rails.logger.info(
        message: "Job completed",
        job_class: self.class.name,
        duration: Time.current - start_time
      )
    rescue => e
      Rails.logger.error(
        message: "Job failed",
        job_class: self.class.name,
        error: e.message,
        backtrace: e.backtrace.first(10)
      )
      raise
    end
  end

  private

  def call(*args)
    raise NotImplementedError, "Implement #call method in #{self.class.name}"
  end
end

