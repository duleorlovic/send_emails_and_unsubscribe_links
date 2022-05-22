require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "creates email object and send email" do
    user = users(:user)
    assert_difference "Email.count" do
      assert_difference "ActionMailer::Base.deliveries.size"  do
        UserMailer.weekly_news(user).deliver_now
      end
    end
  end

  test "does not create email object and send email when unsubscribed" do
    user = users(:user)
    UnsubscribeService.new(user).perform_for_action("weekly_news")
    assert_difference "Email.count", 0 do
      assert_difference "ActionMailer::Base.deliveries.size", 0  do
        UserMailer.weekly_news(user).deliver_now
      end
    end

    assert_difference "Email.count" do
      assert_difference "ActionMailer::Base.deliveries.size"  do
        UserMailer.new_message(user, "Hi").deliver_now
      end
    end
  end
end
