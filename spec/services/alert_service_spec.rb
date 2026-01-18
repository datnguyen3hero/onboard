require 'rails_helper'

RSpec.describe AlertService, type: :service do
  let(:alert) { create(:alert, status: :active) }
  let(:acknowledged_alert) { create(:alert, status: :acknowledged) }
  let(:user) { create(:user) }

  describe '#initialize' do
    it 'sets the alert attribute' do
      service = AlertService.new(alert)
      expect(service.alert).to eq(alert)
    end

    it 'accepts nil alert' do
      service = AlertService.new(nil)
      expect(service.alert).to be_nil
    end
  end

  describe '#acknowledge_alert' do
    context 'when alert is not already acknowledged' do
      let(:service) { AlertService.new(alert) }

      it 'acknowledges the alert' do
        expect(alert).to receive(:acknowledge)
        service.acknowledge_alert(user)
      end

      it 'enqueues a notification worker' do
        expect(SendNotificationWorker).to receive(:perform_async).with(user.id, alert.id)
        service.acknowledge_alert(user)
      end

      it 'returns true' do
        allow(SendNotificationWorker).to receive(:perform_async)
        result = service.acknowledge_alert(user)
        expect(result).to be true
      end

      it 'changes alert status to acknowledged' do
        allow(SendNotificationWorker).to receive(:perform_async)
        expect do
          service.acknowledge_alert(user)
        end.to change { alert.reload.status }.from('active').to('acknowledged')
      end

      it 'sets acknowledged_at timestamp' do
        allow(SendNotificationWorker).to receive(:perform_async)
        expect do
          service.acknowledge_alert(user)
        end.to change { alert.reload.acknowledged_at }.from(nil).to(kind_of(Time))
      end
    end

    context 'when alert is already acknowledged' do
      let(:service) { AlertService.new(acknowledged_alert) }

      it 'does not acknowledge the alert again' do
        expect(acknowledged_alert).not_to receive(:acknowledge)
        service.acknowledge_alert(user)
      end

      it 'does not enqueue a notification worker' do
        expect(SendNotificationWorker).not_to receive(:perform_async)
        service.acknowledge_alert(user)
      end

      it 'returns false' do
        result = service.acknowledge_alert(user)
        expect(result).to be false
      end

      it 'does not change alert status' do
        original_status = acknowledged_alert.status
        service.acknowledge_alert(user)
        expect(acknowledged_alert.reload.status).to eq(original_status)
      end
    end

    context 'when alert is nil' do
      let(:service) { AlertService.new(nil) }

      it 'raises NoMethodError when trying to access alert.id' do
        expect do
          service.acknowledge_alert(user)
        end.to raise_error(NoMethodError, /undefined method `id' for nil/)
      end
    end

    context 'when SendNotificationWorker fails' do
      let(:service) { AlertService.new(alert) }

      it 'still acknowledges the alert before worker is enqueued' do
        allow(SendNotificationWorker).to receive(:perform_async).and_raise(StandardError, 'Worker error')

        expect do
          service.acknowledge_alert(user)
        end.to raise_error(StandardError, 'Worker error')

        expect(alert.reload.status).to eq('acknowledged')
      end
    end
  end

  describe 'integration test with Sidekiq::Testing' do
    around do |example|
      Sidekiq::Testing.fake! do
        example.run
      end
    end

    it 'successfully acknowledges an alert and enqueues notification' do
      service = AlertService.new(alert)

      expect do
        service.acknowledge_alert(user)
      end.to change { alert.reload.status }.to('acknowledged')
        .and change(SendNotificationWorker.jobs, :size).by(1)

      # Verify the job arguments
      job = SendNotificationWorker.jobs.last
      expect(job['args']).to eq([user.id, alert.id])
    end

    it 'handles multiple acknowledgment attempts correctly' do
      service = AlertService.new(alert)

      # First acknowledgment should succeed
      first_result = service.acknowledge_alert(user)
      expect(first_result).to be true

      # Second acknowledgment should fail
      second_result = service.acknowledge_alert(user)
      expect(second_result).to be false

      # Should only enqueue one notification
      expect(SendNotificationWorker.jobs.size).to eq(1)
    end

    it 'enqueues job with correct queue' do
      service = AlertService.new(alert)
      service.acknowledge_alert(user)

      job = SendNotificationWorker.jobs.last
      expect(job['queue']).to eq('default')
    end
  end

  describe 'edge cases' do
    context 'with different alert statuses' do
      around do |example|
        Sidekiq::Testing.fake! do
          example.run
        end
      end

      it 'acknowledges resolved alert' do
        resolved_alert = create(:alert, status: :resolved)
        service = AlertService.new(resolved_alert)

        result = service.acknowledge_alert(user)

        expect(result).to be true
        expect(resolved_alert.reload.status).to eq('acknowledged')
      end

      it 'acknowledges dismissed alert' do
        dismissed_alert = create(:alert, status: :dismissed)
        service = AlertService.new(dismissed_alert)

        result = service.acknowledge_alert(user)

        expect(result).to be true
        expect(dismissed_alert.reload.status).to eq('acknowledged')
      end
    end

    context 'with multiple users' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      let(:service) { AlertService.new(alert) }

      around do |example|
        Sidekiq::Testing.fake! do
          example.run
        end
      end

      it 'only acknowledges once regardless of user' do
        result1 = service.acknowledge_alert(user1)
        expect(result1).to be true

        result2 = service.acknowledge_alert(user2)
        expect(result2).to be false

        # Only one notification should be enqueued
        expect(SendNotificationWorker.jobs.size).to eq(1)
        expect(SendNotificationWorker.jobs.last['args']).to eq([user1.id, alert.id])
      end
    end

    context 'with concurrent acknowledgments' do
      around do |example|
        Sidekiq::Testing.inline! do
          example.run
        end
      end

      it 'processes notification immediately in inline mode' do
        service = AlertService.new(alert)

        expect do
          service.acknowledge_alert(user)
        end.to change { alert.reload.status }.to('acknowledged')
      end
    end
  end

  describe 'business logic validation' do
    around do |example|
      Sidekiq::Testing.fake! do
        example.run
      end
    end

    it 'maintains alert state consistency' do
      service = AlertService.new(alert)
      original_title = alert.title

      service.acknowledge_alert(user)

      alert.reload
      expect(alert.title).to eq(original_title)
      expect(alert.status).to eq('acknowledged')
      expect(alert.acknowledged_at).to be_present
    end

    it 'does not modify other alert attributes' do
      service = AlertService.new(alert)
      original_severity = alert.severity
      original_alert_type = alert.alert_type

      service.acknowledge_alert(user)

      alert.reload
      expect(alert.severity).to eq(original_severity)
      expect(alert.alert_type).to eq(original_alert_type)
    end
  end
end

