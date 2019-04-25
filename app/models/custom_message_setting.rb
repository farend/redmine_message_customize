class CustomMessageSetting < Setting

  before_validation :change_format_to_hash
  validate :custom_message_keys_are_available

  def self.find_or_default
    super('plugin_redmine_message_customize')
  end

  def custom_messages(lang=nil)
    if lang.present?
      self.value.dig(:custom_messages, self.class.find_language(lang)) || {}
    else
      self.value[:custom_messages] || {}
    end
  end

  def custom_messages_to_yaml
    if self.custom_messages.blank?
      ''
    elsif self.custom_messages.is_a?(Hash)
      YAML.dump(self.custom_messages)
    else
      self.custom_messages
    end
  end

  def update_custom_messages(messages)
    self.value = {custom_messages: (messages.present? ? messages : {})}
    self.save
  end

  def self.available_messages(lang='en')
    list = I18n.backend.translations[self.find_language(lang).to_sym] || {}
    self.flatten_hash(list)
  end

  def self.flatten_hash(hash=nil)
    hash = self.to_hash unless hash
    hash.each_with_object({}) do |(key, value), content|
      next self.flatten_hash(value).each do |k, v|
        content["#{key}.#{k}".intern] = v
      end if value.is_a? Hash
      content[key] = value
    end
  end

  def self.to_nested_hash(hash=nil)
    hash = self.to_hash unless hash
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

  def self.reload_translations!(languages)
    paths = ::I18n.load_path.select {|path| self.find_language(languages).include?(File.basename(path, '.*').to_s)}
    I18n.backend.load_translations(paths)
  end

  def self.find_language(language=nil)
    if language.is_a?(Array)
      language.select{|l| I18n.available_locales.include?(l.to_s.to_sym)}.map(&:to_s).compact
    elsif language.present? && I18n.available_locales.include?(language.to_s.to_sym)
      language.to_s
    else
      nil
    end
  end

  private

  def custom_message_keys_are_available
    return false if self.value[:custom_messages].is_a?(Hash) == false || self.errors.present?
    custom_messages_hash = {}
    custom_messages.values.each do |hash|
      custom_messages_hash = self.class.flatten_hash(custom_messages_hash.merge(hash))
    end
    available_keys = self.class.flatten_hash(self.class.available_messages).keys
    unavailable_keys = custom_messages_hash.keys.reject{|k|available_keys.include?(k.to_sym)}
    if unavailable_keys.present?
      self.errors.add(:base, l(:error_unavailable_keys) + "keys: [#{unavailable_keys.join(', ')}]")
      return false
    end
  end

  def change_format_to_hash
    begin
      if self.value[:custom_messages].is_a?(Hash)
        YAML.dump(self.value[:custom_messages])
      else
        self.value = {custom_messages: YAML.load(self.value[:custom_messages])}
      end
    rescue => e
      self.errors.add(:base, e.message)
      return false
    end
  end
end