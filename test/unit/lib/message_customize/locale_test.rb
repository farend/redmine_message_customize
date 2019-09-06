require File.expand_path('../../../../test_helper', __FILE__)

class LocaleTest < ActiveSupport::TestCase
  fixtures :custom_message_settings
  include Redmine::I18n

    def setup
      MessageCustomize::Locale.reload!('en')
      I18n.load_path = (I18n.load_path + Dir.glob(Rails.root.join('plugins', 'redmine_message_customize', 'config', 'locales', 'custom_messages', '*.rb'))).uniq
    end

  def test_reload!
    # Reset @available_messages
    MessageCustomize::Locale.instance_variable_set(:@available_messages, {})

    setting = CustomMessageSetting.find(1)
    setting.value = {custom_messages: { 'en' => { 'label_home' => 'Changed home' }}}
    setting.save

    assert_equal 'Home1', I18n.backend.send(:translations)[:en][:label_home]
    MessageCustomize::Locale.reload!('en')
    assert_equal 'Changed home', I18n.backend.send(:translations)[:en][:label_home]
    assert_equal [:en], MessageCustomize::Locale.instance_variable_get(:@available_messages).keys
  end

  # If this test fails:
  #  Check if you need to change plugins/redmine_message_customize/config/locales/custom_messages.
  def test_available_locales
    locales = %w[ar az bg bs ca cs da de el en en-GB es es-PA et eu fa fi fr gl he hr hu id it ja ko lt lv mk mn nl no pl pt pt-BR ro ru sk sl sq sr sr-YU sv th tr uk vi zh zh-TW]
    assert_equal locales.uniq.sort.map(&:to_sym), MessageCustomize::Locale.available_locales
  end

  def test_available_messages_should_return_translations
    # Reset @available_messages
    MessageCustomize::Locale.instance_variable_set(:@available_messages, {})

    en_available_messages = MessageCustomize::Locale.available_messages('en')
    assert_equal 'am', en_available_messages[:time][:am]
    assert_equal [:en], MessageCustomize::Locale.instance_variable_get(:@available_messages).keys

    # Language 'ar' not loaded
    ar_available_messages = MessageCustomize::Locale.available_messages('ar')
    assert_equal "صباحا", ar_available_messages[:time][:am]
    assert_equal [:en, :ar], MessageCustomize::Locale.instance_variable_get(:@available_messages).keys
  end
end
