class LongTaskWorker < BaseWorker
  # include Sidekiq::Worker

  BACKOFF_DELAY_SECONDS = 5

  sidekiq_options queue: :long_tasks,
                  retry: 3,
                  backtrace: true

  # Short, predictable backoff to make retries easy to observe during testing.
  sidekiq_retry_in do |retry_count, exception, job|
    Rails.logger.warn(
      "LongTaskWorker scheduling retry #{retry_count + 1} for jid=#{job['jid']} queue=#{job['queue']} in #{BACKOFF_DELAY_SECONDS}s: #{exception.message}"
    )
    BACKOFF_DELAY_SECONDS
  end

  sidekiq_retries_exhausted do |job, exception|
    Rails.logger.error("LongTaskWorker retries exhausted after #{job['retry_count']} attempts for jid=#{job['jid']} queue=#{job['queue']}: #{exception.message}")
  end

  # def perform(*args)
  #   Rails.logger.info("LongTaskWorker#perform with args: #{args.inspect}")
  #   sleep_time = rand(1..10)
  #   Rails.logger.info "LongTaskWorker jid=#{jid} started for #{sleep_time} seconds"
  #   # raise StandardError, 'Simulated random failure in LongTaskWorker' if rand(2).zero?
  #
  #   sleep(sleep_time.seconds)
  #   Rails.logger.info "LongTaskWorker jid=#{jid} finished"
  # rescue StandardError => e
  #   Rails.logger.error "LongTaskWorker jid=#{jid} encountered an error: #{e.message}"
  #   raise e
  # end

  def call(*args)
    Rails.logger.info("LongTaskWorker#perform with args: #{args.inspect}")
    sleep_time = rand(1..10)
    Rails.logger.info "LongTaskWorker jid=#{jid} started for #{sleep_time} seconds"
    # raise StandardError, 'Simulated random failure in LongTaskWorker' if rand(2).zero?

    sleep(sleep_time.seconds)
    Rails.logger.info "LongTaskWorker jid=#{jid} finished"
  rescue StandardError => e
    Rails.logger.error "LongTaskWorker jid=#{jid} encountered an error: #{e.message}"
    raise e
  end
end
