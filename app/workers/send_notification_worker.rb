class SendNotificationWorker < BaseWorker
  # include Sidekiq::Worker
  sidekiq_options queue: :alert_acknowledgments, # if we do not specify, it goes to `default` queue
                  # sidekiq_options queue: :default, # if we do not specify, it goes to `default` queue
                  retry: 5, # Retry up to 5 times
                  backtrace: true,
                  dead: true, # Enable dead job queue
                  throttle: { threshold: 1000, period: 1.hour },
                  tags: ['alert', 'notification']

  sidekiq_retries_exhausted do |msg, ex|
    Rails.logger.error "SendNotificationWorker: Failed to send notification for User ##{msg['args'][0]} and Alert ##{msg['args'][1]} after #{msg['retry_count']} attempts. Error: #{ex.message}"
  end

  # def perform(user_id, alert_id)
  #   Rails.logger.info "SendNotificationWorker: Sending notification to User ##{user_id} for Alert ##{alert_id}"
  #   user = User.find_by(id: user_id)
  #   # return unless user
  #   if user.nil?
  #     raise StandardError, "No user found for Alert ##{alert_id}"
  #   end
  #
  #   if rand(2).zero?
  #     raise StandardError, 'Simulated random failure in SendNotificationWorker'
  #   end
  #
  #   Rails.logger.info "Sent notification to User ##{user.id} for Alert ##{alert_id}"
  #
  #   # rescue StandardError => e
  #   #   Rails.logger.error "SendNotificationWorker encountered an error: #{e.message}"
  #   # Re-raise original exception so Sidekiq will handle retries according to `sidekiq_options`
  #   # raise e
  #   # raise Sidekiq::SidekiqSafeRetry.new(e), "#{e.message}. Try to retry again."
  # end

  def call(user_id, alert_id)
    Rails.logger.info "SendNotificationWorker: Sending notification to User ##{user_id} for Alert ##{alert_id}"
    user = User.find_by(id: user_id)
    # return unless user
    if user.nil?
      raise StandardError, "No user found for Alert ##{alert_id}"
    end

    if rand(2).zero?
      raise StandardError, 'Simulated random failure in SendNotificationWorker'
    end

    Rails.logger.info "Sent notification to User ##{user.id} for Alert ##{alert_id}"

    # rescue StandardError => e
    #   Rails.logger.error "SendNotificationWorker encountered an error: #{e.message}"
    # Re-raise original exception so Sidekiq will handle retries according to `sidekiq_options`
    # raise e
    # raise Sidekiq::SidekiqSafeRetry.new(e), "#{e.message}. Try to retry again."
  end
end
