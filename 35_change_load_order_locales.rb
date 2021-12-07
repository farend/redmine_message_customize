# frozen_string_literal: true

require 'redmine/plugin'
if Redmine::Plugin.installed? :redmine_message_customize
  p = Redmine::Plugin.find(:redmine_message_customize)
  custom_locales = Dir.glob(File.join(p.directory, 'config', 'locales', 'custom_messages', '*.rb'))
  Rails.application.config.i18n.load_path = (Rails.application.config.i18n.load_path - custom_locales + custom_locales)
end
