require 'test_helper'

class WeeklyRemainderWorkerTest < ActiveSupport::TestCase
  def create_user!(attr = {})
    user = users(:user).dup
    user.email = "#{rand}@email.com"
    user.password = "password"
    user.assign_attributes attr
    user.save!
    user
  end

  def test_example
    users = []
    users.append create_user!
    users.append create_user! unsubscribe_email_groups: ["remainders"]
    users.append create_user! unsubscribe_email_groups: ["messages"]

    assert_emails 2 do
      result = WeeklyRemainderWorker.new.perform(users)
      assert result.success?
      assert_equal "OK", result.message
    end
  end
end
