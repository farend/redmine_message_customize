module CustomMessageSettingsHelper
  CustomizableNameClasses = [CustomField, IssueCategory, IssuePriority, IssueStatus, Tracker]
  def available_message_options(setting, lang)
    options = [['', '']] +
                CustomMessageSetting.available_messages(lang).map{|k, v| ["#{k}: #{v}", k]}

    options_for_select(options, disabled: setting.custom_messages_to_flatten_hash(lang).keys)
  end

  def normal_mode_input_fields(setting, lang)
    return '' if setting.value[:custom_messages].is_a?(String) || setting.value[:custom_messages].blank?
    content = ActiveSupport::SafeBuffer.new
    custom_messages_hash = setting.custom_messages_to_flatten_hash(lang.to_s)
    custom_messages_hash, custom_names = custom_messages_hash.to_a.partition{|k, v| !k.to_s.include?('custom_object_name') }

    custom_messages_hash.to_h.each do |k, v|
      content += content_tag(:p) do
        content_tag(:label, k) +
        text_field_tag("settings[custom_messages[#{k}]]", v.to_s) +
        link_to_function('', '$(this).closest("p").remove();', class: 'icon icon-del clear-key-link')
      end
    end

    custom_names.each do |k, v|
      content += hidden_field_tag("settings[custom_messages[#{k}]]", v)
    end
    content
  end

  def customizable_name_options(setting, lang)
    options = CustomizableNameClasses.map{|c| [c, c.all.map{|r| [r[:name], "#{c.to_s.underscore}_#{r.id}"]}]}

    disabled = setting.custom_names(lang).keys
    grouped_options_for_select(options, disabled: disabled)
  end

  def customizable_name_input_fields(setting, lang)
    contents = ActiveSupport::SafeBuffer.new
    selected_names = setting.custom_names(lang)

    CustomizableNameClasses.each do |cl|
      original_names = cl.all.select(:id, :name)
      names = selected_names.select{|v| v.include?(cl.to_s.underscore)}

      contents +=
        content_tag(:div, id: cl.to_s.underscore, class: 'class-box') do
          concat content_tag(:span, cl.to_s)
          names.each do |key, value|
            concat(content_tag(:p) do
              concat content_tag(:label, original_names.find(key.delete("^0-9").to_i)[:name])
              concat text_field_tag("settings[custom_names[#{key}]]", value)
              concat link_to_function('', '$(this).closest("p").remove();', class: 'icon icon-del clear-key-link')
            end)
          end
        end
    end
    contents
  end
end