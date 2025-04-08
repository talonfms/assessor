ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "webmock/minitest"
require "sidekiq/testing"
require "mocha/minitest"

# Uncomment to view full stack trace in tests
# Rails.backtrace_cleaner.remove_silencers!

Sidekiq::Testing.fake!

if defined?(Sidekiq)
  require "sidekiq/testing"
  Sidekiq.logger.level = Logger::WARN
end

if defined?(SolidQueue)
  SolidQueue.logger.level = Logger::WARN
end

def sign_in_as_admin(user, account)
  account_user = AccountUser.find_or_create_by(user: user, account: account)
  account_user.update(roles: {"admin" => true})
  Current.account = account
  sign_in user
end

def sign_in_as_member(user, account)
  account_user = AccountUser.find_or_create_by(user: user, account: account)
  account_user.update!(roles: {"member" => true, "admin" => false})
  Current.account = account
  Current.user = user
  sign_in user
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def json_response
      JSON.decode(response.body)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers

    def switch_account(account)
      patch "/accounts/#{account.id}/switch"
    end
  end
end

WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: [
    "chromedriver.storage.googleapis.com",
    "rails-app",
    "selenium"
  ]
})

module ActiveStorageHelpers
  def attach_file_to_fixture(fixture, attribute, file_path, content_type)
    attachment = fixture.public_send(attribute)

    if attachment.respond_to?(:attach)
      attachment.attach(
        io: File.open(file_path),
        filename: File.basename(file_path),
        content_type: content_type
      )
    else
      fixture.public_send(attribute).attach(
        io: File.open(file_path),
        filename: File.basename(file_path),
        content_type: content_type
      )
    end
  end
end
