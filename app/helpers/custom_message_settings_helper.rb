module CustomMessageSettingsHelper
  def available_message_options(setting, lang)
    options = [['', '']] +
                CustomMessageSetting.available_messages(lang).map{|k, v| ["#{k}: #{v}", k]}

    options_for_select(options, disabled: setting.custom_messages_to_flatten_hash(lang).keys)
  end

  def normal_mode_input_fields(setting, lang)
    return '' if setting.value[:custom_messages].is_a?(String) || setting.value[:custom_messages].blank?
    content = ActiveSupport::SafeBuffer.new
    custom_messages_hash = setting.custom_messages_to_flatten_hash(lang.to_s)
    custom_messages_hash.each do |k, v|
      content += content_tag(:p) do
        content_tag(:label, k) +
        text_field_tag("settings[custom_messages[#{k}]]", v.to_s) +
        link_to_function('', '$(this).closest("p").remove();', class: 'icon icon-del clear-key-link')
      end
    end
    content
  end
end