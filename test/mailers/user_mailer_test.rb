require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "new_message contains unsubscribe_link" do
    user = users(:user)
    mail = UserMailer.new_message user, "Hi"
    assert_equal "New message", mail.subject
    assert_equal [user.email], mail.to
    assert_match "Hi", mail.body.encoded
    unsubscribe_link = mail.body.encoded.match(
      /<a href="(http:\S*)".*>unsubscribe<\/a>/
    ).captures.first
    assert unsubscribe_link
  end

  test "weekly_news contains unsubscribe_link" do
    user = users(:user)
    mail = UserMailer.weekly_news user
    assert_equal "Weekly news", mail.subject
    assert_equal [user.email], mail.to
    assert_match "Last week", mail.body.encoded
    unsubscribe_link = mail.body.encoded.match(
      /<a href="(http:\S*)".*>unsubscribe<\/a>/
    ).captures.first
    assert unsubscribe_link
  end
end
