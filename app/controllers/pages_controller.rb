class PagesController < ApplicationController
  def index
  end

  def sign_in_development
    return unless Rails.env.development? || Rails.application.secrets.is_staging

    user = User.find params[:id]
    sign_in :user, user, bypass: true
    redirect_to params[:redirect_to] || root_path
  end

  def unsubscribe
    @unsubscribe_form = UnsubscribeForm.new _unsubscribe_form_params
    if @unsubscribe_form.unsubscribe_from_token
      flash.notice = @unsubscribe_form.message
    elsif @unsubscribe_form.user.present?
      # keep on unsubscribe_form page
      flash.alert = @unsubscribe_form.errors.full_messages.to_sentence
    else
      flash.alert = @unsubscribe_form.errors.full_messages.to_sentence
      redirect_to root_path
    end
  end

  def unsubscribe_post
    @unsubscribe_form = UnsubscribeForm.new _unsubscribe_form_params
    if @unsubscribe_form.deselect_groups
      flash.notice = @unsubscribe_form.message
      redirect_to unsubscribe_path(token: @unsubscribe_form.token_for_blank_action)
    elsif @unsubscribe_form.user.present?
      # keep on unsubscribe_form page
      flash.alert = @unsubscribe_form.errors.full_messages.to_sentence
      redirect_to unsubscribe_path(token: @unsubscribe_form.token_for_blank_action)
    else
      flash.alert = @unsubscribe_form.errors.full_messages.to_sentence
      redirect_to root_path
    end
  end

  def _unsubscribe_form_params
    params[:unsubscribe_form] = {groups: []} unless params.keys.include? "unsubscribe_form"
    params.require(:unsubscribe_form).permit(
      groups: [],
    ).merge(
      token: params[:token]
    )
  end
end
