module CustomMessageSettingsHelper
  def available_messages(lang)
    messages = I18n.backend.translations[lang.to_sym]
    if messages.nil?
      CustomMessageSetting.reload_translations!([lang])
      messages = I18n.backend.translations[lang.to_sym] || {}
    end

    CustomMessageSetting.flatten_hash(messages)
  end

  def available_message_options(lang)
    [['', '']] +
    available_messages(lang).map do |k, v|
      ["#{k}: #{v}", k]
    end
  end

  def normal_mode_input_fields(setting, lang)
    return '' if setting.value[:custom_messages].is_a?(String) || setting.value[:custom_messages].blank?
    content = ''
    custom_messages_hash = CustomMessageSetting.flatten_hash(setting.custom_messages[lang.to_s] || {})
    custom_messages_hash.each do |k, v|
      content += content_tag(:p) do
        content_tag(:label, k) +
        text_field_tag("settings[custom_messages[#{k}]]", v.to_s) +
        link_to_function('', '$(this).closest("p").remove();', class: 'icon-only icon-del clear-key-link')
      end
    end
    content.html_safe
  end
end