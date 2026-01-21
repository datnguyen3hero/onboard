# frozen_string_literal: true

class AlertConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      Rails.logger.info "Received message: #{message.to_json}"
      handle_alert(message.payload)
    rescue StandardError => e
      Rails.logger.error "Error processing message #{message.to_json}: #{e.message}"
      raise e
    end
  end

  # Run anything upon partition being revoked
  def revoked
    Rails.logger.info 'Partition revoked'
  end

  # Define here any teardown things you want when Karafka server stops
  def shutdown
    Rails.logger.info 'Consumer is shutting down'
  end

  def handle_alert(payload)
    event_type = payload['event']
    data = payload['data']
    case event_type
    when 'create'
      Rails.logger.info "Alert summary created: #{data}"
      alert_summary = SummaryMessageService.new(data[:body]).generate_summary
      data['summary'] = alert_summary
      AlertSummary.create_from_mapped_data!(data)
    when 'update'
      Rails.logger.info "Alert summary updated: #{data}"
      existed_record = AlertSummary.find_by(title: data['title'])
      if existed_record.nil?
        Rails.logger.warn "Alert summary to update not found: #{data}"
        return
      end
      alert_summary = SummaryMessageService.new(data[:body]).generate_summary
      data['summary'] = alert_summary
      existed_record.update_from_mapped_data!(data)
    when 'delete'
      Rails.logger.info "Alert summary deleted: #{data}"
      existed_record = AlertSummary.find_by(title: data['title'])
      existed_record&.destroy!
    else
      Rails.logger.error "Unknown event type: #{event_type}"
    end
  end
end
