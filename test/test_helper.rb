ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Dir[Rails.root.join('test/a/**/*.rb')].sort.each { |f| require f }

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # devise method: sign_in user
  include Devise::Test::IntegrationHelpers

  # assert_emails 1
  include ActionMailer::TestHelper

  # Add more helper methods to be used by all tests here...
  def assert_valid_fixture(items)
    assert items.map(&:valid?).all?, (items.reject(&:valid?).map { |c| (c.respond_to?(:name) ? "#{c.name} " : '') + c.errors.full_messages.to_sentence })
  end
end
