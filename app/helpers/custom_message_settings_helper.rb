module CustomMessageSettingsHelper
  def available_message_options(setting, lang)
    options = [['', '']] +
                CustomMessageSetting.flatten_hash(MessageCustomize::Locale.available_messages(lang))
                .select{|_k, v| v.is_a?(String)}
                .map{|k, v| ["#{k}: #{v}", k]}

    options_for_select(options, disabled: setting.custom_messages_to_flatten_hash(lang).keys)
  end

  def normal_mode_input_fields(setting, lang)
    return '' if setting.custom_messages.is_a?(String) || setting.custom_messages.blank?

    content = ActiveSupport::SafeBuffer.new
    custom_messages_hash = setting.custom_messages_to_flatten_hash(lang.to_s)
    custom_messages_hash.each do |k, v|
      content += content_tag(:p) do
        content_tag(:label, k) +
        text_field_tag("settings[custom_messages][#{k}]", v.to_s) +
        link_to_function(sprite_icon('del'), '$(this).closest("p").remove()', class: 'icon clear-key-link')
      end
    end
    content
  end

  def open_default_messages_window_link(lang)
    link_to sprite_icon('file', l(:label_default_messages)),
            default_messages_custom_message_settings_path(lang: lang),
            class: 'icon text-plain',
            onclick: "window.open(this.href,'redmine_message_customize_plugin-default_messages', 'height=800, width=500');return false;",
            id: 'default-messages-link'
  end
end
