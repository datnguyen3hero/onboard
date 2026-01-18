require "test_helper"

class AlertTest < ActiveSupport::TestCase
  test ".for_user returns alerts for the given user" do
    alice = users(:one)
    alerts_for_alice = Alert.for_user(alice)

    assert_equal %w[Welcome Reminder].sort, alerts_for_alice.pluck(:title).sort
  end

  test ".for_user ignores other users' alerts" do
    bob = users(:two)

    assert_equal ["Reminder"], Alert.for_user(bob).pluck(:title)
  end

  test ".for_user accepts an id" do
    user_id = users(:one).id

    assert_equal ["Welcome", "Reminder"].sort, Alert.for_user(user_id).pluck(:title).sort
  end
end
