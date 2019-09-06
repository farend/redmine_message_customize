# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

# Add missing settings when ENV['RAILS_ENV'] is development
if Rails.env.development?
  Rails.application.config.redmine_verify_sessions = false
  Rails.application.config.action_controller.allow_forgery_protection = false
  ActionController::Base.allow_forgery_protection = false
end

ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures', 'custom_message_settings')