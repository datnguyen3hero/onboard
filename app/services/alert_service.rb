class AlertService

  attr_reader :alert

  def initialize(alert)
    @alert = alert
  end

  def acknowledge_alert(user)
    SendNotificationWorker.perform_async(user.id, @alert.id)
    FeatureFlagAssistant.on?(:feature_code,  {
      organisation: "organisation_uuid",
      member: "member_uuid",
      user: "user_uuid"
    })


    if alert&.acknowledge?
      false
    else
      alert&.acknowledge
      SendNotificationWorker.perform_async(user.id, @alert.id)
      true
    end
  end
end


