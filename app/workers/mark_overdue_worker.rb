class MarkOverdueWorker
  include Sidekiq::Worker

  def perform
    Rails.logger.info 'Mark overdue job started'
    overdue = Alert.overdue
    count = overdue.count
    overdue.map(&:mark_overdue)
    Rails.logger.info "Marked #{count} alerts as overdue"
    Rails.logger.info 'Mark overdue job finished'
  end
end
