class UnsubscribeService
  @@verifier = ActiveSupport::MessageVerifier.new Rails.application.credentials.secret_key_base

  # https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
  def self.link_to_unsubscribe_for_user_id_and_action(user_id, action)
    Rails.application.routes.url_helpers.unsubscribe_url token: token_for_user_id_and_action(user_id, action)
  end

  def self.token_for_user_id_and_action(user_id, action)
    @@verifier.generate [user_id, action]
  end

  # https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html#method-i-verified
  def self.parse_unsubscribe_token_to_get_user_id_and_action(token)
    @@verifier.verified token
  end

  def self.group_for_email_action_name(action)
    group, _ = Const.unsubscribe_group_to_email_action_names.find { |_k, v| v.include? action }
    raise "can_not_find_group action=#{action}" if group.blank?
    group
  end

  def initialize(user)
    @user = user
  end

  def perform_for_action(action)
    group = self.class.group_for_email_action_name action
    perform_for_group group
  end

  def perform_for_group(group)
    @user.unsubscribe_email_groups ||= []
    if @user.unsubscribe_email_groups.include? group
      Error.new "You are already unsubscribed from #{group}"
    else
      @user.unsubscribe_email_groups.append(group)
      @user.save!
      Result.new "Successfully unsubscribed from #{group}"
    end
  end

  def subscribe_for_group(group)
    @user.unsubscribe_email_groups ||= []
    if @user.unsubscribe_email_groups.include? group
      @user.unsubscribe_email_groups = @user.unsubscribe_email_groups - [group]
      @user.save!
      Result.new "Successfully subscribed to #{group}"
    else
      Error.new "You are already subscribed to #{group}"
    end
  end

  def unsubscribed_from_action?(action)
    @user.unsubscribe_email_groups.include?  self.class.group_for_email_action_name(action)
  end
end
