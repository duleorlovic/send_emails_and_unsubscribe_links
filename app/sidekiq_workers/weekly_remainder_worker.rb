require 'sidekiq-scheduler'

class WeeklyRemainderWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'my_app_default'

  def perform(users = User.all)
    articles_count = Article.where(created_at: 1.week.ago..).count
    message = "There are #{ActionController::Base.helpers.pluralize(articles_count, 'articles')} created previous week"

    iterate_users(users) do |user|
      UserMailer.weekly_news(user, message).deliver_later
    end

    Result.new "OK"
  end

  def iterate_users(users, &block)
    if users.is_a? ActiveRecord::Relation
      users.find_each do |user|
        block.call user
      end
    else
      users.each do |user|
        block.call user
      end
    end
  end
end
