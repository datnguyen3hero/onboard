class AlertService

  attr_reader :alert

  def initialize(alert)
    @alert = alert
  end

  def acknowledge_alert(user)
    test_fl = FeatureFlagAssistant.on?(:dat_nguyen_local_fl_test_01, {
      organisation: "organisation_uuid",
      member: "member_uuid",
      user: "user_uuid"
    })

    # Similate the case when feature flag is off
    # if test_fl == false
    #   Rails.logger.warn "Feature flag 'dat_nguyen_local_fl_test_01' is OFF. Skipping alert acknowledgment."
    #   return false
    # end


    if alert&.acknowledge?
      false
    else
      alert&.acknowledge
      SendNotificationWorker.perform_async(user.id, @alert.id)
      true
    end
  end
end


