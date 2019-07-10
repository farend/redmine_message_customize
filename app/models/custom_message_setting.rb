class CustomMessageSetting < Setting
  validate :add_errors, :convertible_to_yaml,
           :custom_message_languages_are_available, :custom_message_keys_are_available

  def self.find_or_default
    super('plugin_redmine_message_customize')
  end

  def enabled?
    self.value[:enabled] != 'false'
  end

  def custom_messages(lang=nil, check_enabled=false)
    messages = self.value[:custom_messages] || self.value['custom_messages']
    if lang.present?
      messages = messages.with_indifferent_access[lang.to_s]
    end

    if messages.blank? || (check_enabled && !self.enabled?)
      {}
    else
      messages
    end
  end

  def custom_messages_to_flatten_hash(lang=nil)
    self.class.flatten_hash(custom_messages(lang))
  end

  def custom_messages_to_yaml
    messages = self.custom_messages
    if messages.blank?
      ''
    elsif messages.is_a?(Hash)
      YAML.dump(messages)
    else
      messages
    end
  end

  def update_with_custom_messages(custom_messages, lang)
    value = CustomMessageSetting.nested_hash(custom_messages)
    original_custom_messages = self.custom_messages
    messages =
      if value.present?
        original_custom_messages.merge({lang => value})
      else
        original_custom_messages.delete(lang)
        original_custom_messages
      end

    self.value = {custom_messages: (messages.present? ? messages : {})}
    self.save
  end

  def update_with_custom_messages_yaml(yaml)
    begin
      messages = YAML.load(yaml)
      @errs = {base: l(:error_invalid_yaml_format) } if !messages.is_a?(Hash) && messages.present?
      self.value = {custom_messages: (messages.present? ? messages : {})}
    rescue => e
      @errs = {base: e.message}
      self.value = {custom_messages: yaml}
    end
    self.save
  end

  def toggle_enabled!
    self.value = self.value.deep_merge({enabled: (!self.enabled?).to_s})

    if result = self.save
      MessageCustomize::Locale.reload!(self.using_languages)
    end
    result
  end

  def using_languages
    messages = self.custom_messages
    if messages.is_a?(Hash)
      messages.keys.map(&:to_s)
    else
      [User.current.language]
    end
  end

  def self.available_messages(lang)
    lang = :"#{lang}"
    messages = I18n.backend.send(:translations)[lang]
    if messages.nil?
      MessageCustomize::Locale.reload!([lang])
      messages = I18n.backend.send(:translations)[lang] || {}
    end
    self.flatten_hash(messages)
  end

  # { date: { formats: { defaults: '%m/%d/%Y'}}} to {'date.formats.defaults' => '%m/%d/%Y'}
  def self.flatten_hash(hash=nil)
    hash = self.to_hash unless hash
    hash.each_with_object({}) do |(key, value), content|
      next self.flatten_hash(value).each do |k, v|
        content["#{key}.#{k}".intern] = v
      end if value.is_a? Hash
      content[key] = value
    end
  end

  # {'date.formats.defaults' => '%m/%d/%Y'} to { date: { formats: { defaults: '%m/%d/%Y'}}}
  def self.nested_hash(hash=nil)
    new_hash = {}
    hash.each do |key, value|
      h = value
      h = YAML.load(value) if value.first == '[' && value.last == ']'
      key.to_s.split('.').reverse_each do |k|
        h = {k => h}
      end
      new_hash = new_hash.deep_merge(h)
    end
    new_hash
  end

  private

  def custom_message_keys_are_available
    return false if !value[:custom_messages].is_a?(Hash) || errors.present?

    custom_messages_hash = {}
    custom_messages.values.compact.each do |val|
      custom_messages_hash = self.class.flatten_hash(custom_messages_hash.merge(val)) if val.is_a?(Hash)
    end
    available_keys = self.class.flatten_hash(self.class.available_messages('en')).keys
    unavailable_keys = custom_messages_hash.keys.reject{|k| available_keys.include?(k.to_sym)}
    if unavailable_keys.present?
      self.errors.add(:base, l(:error_unavailable_keys) + " keys: [#{unavailable_keys.join(', ')}]")
      false
    end
  end

  def custom_message_languages_are_available
    return false if !value[:custom_messages].is_a?(Hash) || errors.present?

    unavailable_languages =
      custom_messages.keys.compact.reject do |language|
        MessageCustomize::Locale.available_locales.include?(language.to_sym)
      end
    if unavailable_languages.present?
      self.errors.add(:base, l(:error_unavailable_languages) + " [#{unavailable_languages.join(', ')}]")
      false
    end
  end

  def convertible_to_yaml
    YAML.dump(self.value[:custom_messages])
  end

  def add_errors
    if @errs.present?
      @errs.each do |key, value|
        self.errors.add(key, value)
      end
      @errs = nil
      false
    end
  end
end