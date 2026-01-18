require "test_helper"

class BaseAPITest < ActionDispatch::IntegrationTest
  test "creates an alert via grape" do
    payload = { title: "New", body: "Body", active: true, type: "Alert" }

    post "/api/v1/alerts", params: payload, as: :json

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "New", body["title"]
  end

  test "subscribes a user to an alert via grape" do
    alert = alerts(:welcome)
    user = users(:two)

    post "/api/v1/alerts/#{alert.id}/subscriptions", params: { user_id: user.id }, as: :json

    assert_response :created
    assert_includes Alert.for_user(user).pluck(:id), alert.id
  end

  test "unsubscribes a user from an alert via grape" do
    alert = alerts(:reminder)
    user = users(:one)

    delete "/api/v1/alerts/#{alert.id}/subscriptions/#{user.id}", as: :json

    assert_response :no_content
    refute_includes Alert.for_user(user).pluck(:id), alert.id
  end

  test "lists alerts for user via grape" do
    user = users(:one)

    get "/api/v1/users/#{user.id}/alerts"

    assert_response :success
    titles = JSON.parse(response.body).pluck("title")
    assert_equal %w[Reminder Welcome].sort, titles.sort
  end

  test "lists unsubscribed alerts for user via grape" do
    user = users(:two)

    get "/api/v1/users/#{user.id}/unsubscribed_alerts"

    assert_response :success
    titles = JSON.parse(response.body).pluck("title")
    assert_equal ["Welcome"], titles
  end

  test "lists subscribers for an alert via grape" do
    alert = alerts(:reminder)

    get "/api/v1/alerts/#{alert.id}/users"

    assert_response :success
    names = JSON.parse(response.body).pluck("name")
    assert_equal %w[Alice Bob].sort, names.sort
  end
end
