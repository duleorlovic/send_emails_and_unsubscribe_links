# https://github.com/duleorlovic/rails_helpers_and_const/blob/main/app/forms/registration_form.rb
class UnsubscribeForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  BLANK_ACTION = :blank_action

  FIELDS = %i[groups]
  attr_accessor :user, :action, :token, :message, *FIELDS
  validates :token, presence: true

  before_validation :set_user_and_action_from_token

  def deselect_groups
    return false unless valid?

    unsubscribed_groups = []
    subscribed_groups = []
    Const.unsubscribe_group_to_email_action_names.keys.each do |group|
      if groups.include? group
        result = UnsubscribeService.new(@user).subscribe_for_group group
        subscribed_groups.append group if result.success?
      else
        result = UnsubscribeService.new(@user).perform_for_group group
        unsubscribed_groups.append group if result.success?
      end
    end

    @message = "Successfully"
    @message += " unsubscribed from #{unsubscribed_groups.to_sentence}" if unsubscribed_groups.present?
    @message += " subscribed to #{subscribed_groups.to_sentence}" if subscribed_groups.present?
    true
  end

  def set_user_and_action_from_token
    user_id, @action = UnsubscribeService.parse_unsubscribe_token_to_get_user_id_and_action token
    errors.add :base, "UnsubscribeToken is not valid" and return if user_id.blank?

    @user = User.find_by id: user_id
    errors.add :base, "Can not find user" and return if @user.blank?
  end

  def unsubscribe_from_token
    return false unless valid?

    return true if @action == BLANK_ACTION
    result = UnsubscribeService.new(@user).perform_for_action @action
    errors.add :base, result.message and return unless result.success?

    @message = result.message
    true
  end

  def token_for_blank_action
    UnsubscribeService.token_for_user_id_and_action @user.id, BLANK_ACTION
  end
end
