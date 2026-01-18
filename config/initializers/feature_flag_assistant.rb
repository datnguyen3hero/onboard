FeatureFlagAssistant.logger = Rails.logger

if Rails.env.development? && ENV['DISABLE_FEATURE_FLAG'] == 'true'
  # All value returned by Feature Flag is `true`
  # The default value can be changed by FeatureFlagAssistant.stub_all!(default: false)
  FeatureFlagAssistant.stub_all!

  # OR
  # Define the list of value yourself
  # Checking features outside the defined list will use fallback value
  # or false if it's not specified
  #
  # EXAMPLE
  # FeatureFlagAssistant.stub!(
  # add_ons: true,
  # spa_dashboard: false,
  # contract_templates: false,
  # fallback: true
  # )
elsif Rails.env.test?
  FeatureFlagAssistant.working_mode = :direct
else
  FeatureFlagAssistant.working_mode = :in_memory
  FeatureFlagAssistant.update_interval = 180 # seconds
  FeatureFlagAssistant.trigger_sync
end
