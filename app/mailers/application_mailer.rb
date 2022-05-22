class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.mailer_sender
  layout "mailer"

  after_action :save_email

  # here we have access to `mail` object
  def save_email
    return unless @user.is_a? User

    if UnsubscribeService.new(@user).unsubscribed_from_action? action_name
      mail.perform_deliveries = false
    else
      @user.emails.create(
        to: @user.email,
        subject: mail.subject,
        body: mail.body,
      )
    end
  end
end
