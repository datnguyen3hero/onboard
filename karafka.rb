# frozen_string_literal: true

class ConsumerMapper
  def self.call(raw_consumer_group_name)
    [
      'my_custom_mapper_prefix', # The customised prefix
      raw_consumer_group_name # The consumer group of the topic
    ].join('_') # Joining 2 strings with '_'
  end
end

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = {
      'bootstrap.servers': '127.0.0.1:9092',
      # https://karafka.io/docs/WaterDrop-Idempotence-and-Acknowledgements/#idempotence
      'enable.idempotence': true,
    }
    config.client_id = 'alert_subscription_app'
    config.concurrency = 5
    config.max_wait_time = 500 # 0.5 second
    # Recreate consumers with each batch. This will allow Rails code reload to work in the
    # development mode. Otherwise Karafka process would not be aware of code changes
    config.consumer_persistence = !Rails.env.development?
    config.consumer_mapper = ConsumerMapper # Define the mapper class
  end

  # Comment out this part if you are not using instrumentation and/or you are not
  # interested in logging events for certain environments. Since instrumentation
  # notifications add extra boilerplate, if you want to achieve max performance,
  # listen to only what you really need for given environment.
  # Karafka.monitor.subscribe(Karafka::Instrumentation::LoggerListener.new)
  # Karafka.monitor.subscribe(Karafka::Instrumentation::ProctitleListener.new)

  # This logger prints the producer development info using the Karafka logger.
  # It is similar to the consumer logger listener but producer oriented.
  Karafka.producer.monitor.subscribe(
    WaterDrop::Instrumentation::LoggerListener.new(
      # Log producer operations using the Karafka logger
      Karafka.logger,
      # If you set this to true, logs will contain each message details
      # Please note, that this can be extensive
      log_messages: false
    )
  )

  # routes.draw do
  #   # Uncomment this if you use Karafka with ActiveJob
  #   # You need to define the topic per each queue name you use
  #   # active_job_topic :default
  #   topic :example do
  #     # Uncomment this if you want Karafka to manage your topics configuration
  #     # Managing topics configuration via routing will allow you to ensure config consistency
  #     # across multiple environments
  #     #
  #     config(partitions: 2, 'cleanup.policy': 'compact')
  #     consumer ExampleConsumer
  #   end
  # end


  consumer_groups.draw do
    consumer_group 'Onboarding.AlertSubscription.Alert' do
      topic 'Onboarding.AlertSubscription.Alert' do
        # https://karafka.io/docs/WaterDrop-Idempotence-and-Acknowledgements/#replication-factor
        config(
          partitions: 2,
          replication_factor: 1
        )
        consumer AlertConsumer
      end
    end
  end

end

# Karafka now features a Web UI!
# Visit the setup documentation to get started and enhance your experience.
#
# https://karafka.io/docs/Web-UI-Getting-Started

Karafka::Web.setup do |config|
  # You may want to set it per ENV. This value was randomly generated.
  config.ui.sessions.secret = 'f04111a7c23bed380cf27e8937ea59baed36414079f8184a01e49690e664a2c8'
end

Karafka::Web.enable!

