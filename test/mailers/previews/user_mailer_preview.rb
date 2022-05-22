# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/new_message
  def new_message
    UserMailer.new_message User.last, "Hi"
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/weekly_news
  def weekly_news
    UserMailer.weekly_news User.last
  end

end
