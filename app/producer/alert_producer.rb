# frozen_string_literal: true

class AlertProducer

  def initialize(alert)
    @alert = alert
  end

  EVENT_TYPES = %w[create update delete].freeze

  def publish(event_type)
    raise ArgumentError, "Invalid event type: #{event_type}" unless EVENT_TYPES.include?(event_type)

    # produce_async will not wait the response from Kafka
    Karafka.producer.produce_sync(
      topic: 'Onboarding.AlertSubscription.Alert',
      payload: {
        event: event_type,
        data: @alert
      }.to_json
    )
  end
end
