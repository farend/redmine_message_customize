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
      messages = messages[lang.to_s]
    end

    if messages.nil? || (check_enabled && !self.enabled?)
      {}
    else
      messages
    end
  end

  def custom_messages_to_flatten_hash(lang=nil)
    self.class.flatten_hash(custom_messages(lang))
  end

  def custom_messages_to_yaml
    if yaml = @invalid_yaml
      @invalid_yaml = nil
      yaml
    else
      custom_messages.present? ? YAML.dump(custom_messages) : ''
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

    self.value = {custom_messages: messages.presence || {}}
    self.save
  end

  def update_with_custom_messages_yaml(yaml)
    messages = YAML.load(yaml)
    raise l(:error_invalid_yaml_format) if messages.present? && !messages.is_a?(Hash)
    self.value = {custom_messages: messages.presence || {}}
    self.save
  rescue => e
    @errs = {base: e.message}
    @invalid_yaml = yaml
    self.valid?
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

  # { date: { formats: { defaults: '%m/%d/%Y'}}} to {'date.formats.defaults' => '%m/%d/%Y'}
  def self.flatten_hash(hash=nil)
    hash ||= self.to_hash

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
    return if errors.present?

    en_translation_hash = self.class.flatten_hash(MessageCustomize::Locale.available_messages('en'))
    custom_message_keys = custom_messages.values.inject([]){|ar, val| ar + self.class.flatten_hash(val).keys}.uniq

    unused_keys = custom_message_keys.reject{|k| en_translation_hash.keys.include?(:"#{k}")}
    unusable_type_of_keys = (custom_message_keys - unused_keys).reject{|k| en_translation_hash[:"#{k}"].is_a?(String)}

    if unused_keys.present?
      errors.add(:base, "#{l(:error_unused_keys)} keys: [#{unused_keys.join(', ')}]")
    end
    if unusable_type_of_keys.present?
      errors.add(:base, "#{l(:error_unusable_type_of_keys)} keys: [#{unusable_type_of_keys.join(', ')}]")
    end
  end

  def custom_message_languages_are_available
    return if errors.present?

    unavailable_languages =
      custom_messages.keys.compact.reject do |language|
        MessageCustomize::Locale.available_locales.include?(language.to_sym)
      end
    if unavailable_languages.present?
      self.errors.add(:base, l(:error_unavailable_languages) + " [#{unavailable_languages.join(', ')}]")
    end
  end

  def convertible_to_yaml
    return if errors.present?

    YAML.dump(self.value[:custom_messages])
  end

  def add_errors
    if @errs.present?
      @errs.each do |key, value|
        self.errors.add(key, value)
      end
      @errs = nil
    end
  end
end