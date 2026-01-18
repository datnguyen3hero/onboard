class LongTaskWorker
  include Sidekiq::Worker

  sidekiq_options queue: :long_tasks,
                  retry: 3,
                  backtrace: true

  # Short, predictable backoff to make retries easy to observe during testing.
  # sidekiq_retry_in do |retry_count, exception, job|
  #   delay = 5
  #   Rails.logger.warn("LongTaskWorker scheduling retry #{retry_count + 1} for jid=#{job['jid']} queue=#{job['queue']} in #{delay}s: #{exception.message}")
  #   delay
  # end

  sidekiq_retries_exhausted do |job, exception|
    Rails.logger.error("LongTaskWorker retries exhausted after #{job['retry_count']} attempts for jid=#{job['jid']} queue=#{job['queue']}: #{exception.message}")
  end

  def perform(*args)
    Rails.logger.info("LongTaskWorker#perform with args: #{args.inspect}")
    sleep_time = rand(1..10)
    Rails.logger.info "LongTaskWorker jid=#{jid} started for #{sleep_time} seconds"
    # Simulate a random failure
    if rand(2).zero?
      raise StandardError, 'Simulated random failure in LongTaskWorker'
    end

    sleep(sleep_time.seconds)
    Rails.logger.info "LongTaskWorker jid=#{jid} finished"
  rescue StandardError => e
    Rails.logger.error "LongTaskWorker jid=#{jid} encountered an error: #{e.message}"
    # Re-raise the original exception so Sidekiq's retry mechanism can process it
    raise e
    # raise Sidekiq::SidekiqSafeRetry.new(e), "#{e.message}. Try to retry again."
  end
end
