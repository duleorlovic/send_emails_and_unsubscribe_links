class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.new_message.subject
  #
  def new_message(user, message)
    @user = user
    @message = message

    mail to: user.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.weekly_news.subject
  #
  def weekly_news(user)
    @user = user
    @content = "Last week you have 10 views"

    mail to: user.email
  end
end
