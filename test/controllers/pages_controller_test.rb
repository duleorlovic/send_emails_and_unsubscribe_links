require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pages_index_url
    assert_response :success
  end

  test "#unsubscribe successfully messages" do
    user = users(:user)
    mail = UserMailer.new_message user, "Hi"
    unsubscribe_link = mail.body.encoded.match(
      /<a href="(http:\S*)".*>unsubscribe<\/a>/
    ).captures.first
    get unsubscribe_link
    assert_notice_message "Successfully unsubscribed from messages"
    user.reload
    assert_equal ["messages"], user.unsubscribe_email_groups

    # two times does not add to group twice
    get unsubscribe_link
    assert_notice_message "Successfully unsubscribed from messages"
    user.reload
    assert_equal ["messages"], user.unsubscribe_email_groups
  end

  test "#unsubscribe successfully remainders" do
    user = users(:user)
    mail = UserMailer.weekly_news user
    unsubscribe_link = mail.body.encoded.match(
      /<a href="(http:\S*)".*>unsubscribe<\/a>/
    ).captures.first
    get unsubscribe_link
    assert_notice_message "Successfully unsubscribed from remainders"
    assert_select "input[type=checkbox][value=messages][checked=checked]", 1
    assert_select "input[type=checkbox][value=remainders][checked=checked]", 0
  end

  test "#unsubscribe invalid token" do
    user = users(:user)
    get unsubscribe_path(token: "invalid")
    follow_redirect!
    assert_alert_message "UnsubscribeToken is not valid"
  end

  test "#unsubscribe user is deleted" do
    user = users(:user)
    mail = UserMailer.new_message user, "Hi"
    unsubscribe_link = mail.body.encoded.match(
      /<a href="(http:\S*)".*>unsubscribe<\/a>/
    ).captures.first
    user.destroy!
    get unsubscribe_link
    follow_redirect!
    assert_alert_message "Can not find user"
  end

  test "#unsubscribe_post success" do
    user = users(:user)
    action = "new_message"
    token = UnsubscribeService.token_for_user_id_and_action user.id, action
    post unsubscribe_post_path(token: token, unsubscribe_form: { groups: ["messages", "remainders", "transaction_emails"] })
    user.reload
    assert user.unsubscribe_email_groups.blank?, user.unsubscribe_email_groups

    post unsubscribe_post_path(token: token, unsubscribe_form: { groups: ["messages", "transaction_emails"]})
    user.reload
    assert_equal ["remainders"], user.unsubscribe_email_groups

    # reinclude remainders
    post unsubscribe_post_path(token: token, unsubscribe_form: { groups: ["messages", "remainders", "transaction_emails"]})
    user.reload
    assert_equal [], user.unsubscribe_email_groups
  end
end
