# frozen_string_literal: true

module MessageCustomize
  class Hooks < Redmine::Hook::ViewListener
    # The language file for redmine_message_customize should be given the highest priority because it overrides other plugin languages.
    # Set the language file to be loaded with the highest priority after all plugins have finished loading.
    def after_plugins_loaded(_context)
      p = Redmine::Plugin.find(:redmine_message_customize)
      custom_locales = Dir.glob(File.join(p.directory, 'config', 'locales', 'custom_messages', '*.rb'))
      Rails.application.config.i18n.load_path = (Rails.application.config.i18n.load_path - custom_locales + custom_locales)
    end
  end
end
