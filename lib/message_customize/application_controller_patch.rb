# frozen_string_literal: true

module MessageCustomize
  module ApplicationControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethod)
      base.class_eval do
        before_action :reload_customize_messages
      end
    end

    module InstanceMethod
      def reload_customize_messages
        custom_message_setting = CustomMessageSetting.find_or_default
        return if custom_message_setting.latest_messages_applied?(current_user_language)

        MessageCustomize::Locale.reload!([current_user_language])
      end

      private

      def current_user_language
        User.current.language.presence || Setting.default_language
      end
    end
  end
end

ApplicationController.include(MessageCustomize::ApplicationControllerPatch)
