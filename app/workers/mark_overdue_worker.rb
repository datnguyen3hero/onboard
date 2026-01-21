class MarkOverdueWorker < BaseWorker
  sidekiq_options queue: :default,
                  retry: 3,
                  backtrace: true,
                  dead: true,
                  tags: ['alert', 'mark_overdue']

  # def perform
  #   Rails.logger.info 'Mark overdue job started'
  #   overdue = Alert.overdue
  #   count = overdue.count
  #   overdue.map(&:mark_overdue)
  #   Rails.logger.info "Marked #{count} alerts as overdue"
  #   Rails.logger.info 'Mark overdue job finished'
  #
  # rescue StandardError => e
  #   Rails.logger.error "MarkOverdueWorker encountered an error: #{e.message}"
  #   raise Sidekiq::SidekiqSafeRetry.new(e), "#{e.message}. Try to retry again."
  # end

  def call
    Rails.logger.info 'Mark overdue job started'
    overdue = Alert.overdue
    count = overdue.count
    overdue.map(&:mark_overdue)
    Rails.logger.info "Marked #{count} alerts as overdue"
    Rails.logger.info 'Mark overdue job finished'

  rescue StandardError => e
    Rails.logger.error "MarkOverdueWorker encountered an error: #{e.message}"
    raise Sidekiq::SidekiqSafeRetry.new(e), "#{e.message}. Try to retry again."
  end
end
