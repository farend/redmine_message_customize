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

  def test_available_messages_if_customizable_plugin_messages
    MessageCustomize::Locale.stubs(:customizable_plugin_messages?).returns(true)

    # Reset @available_messages
    MessageCustomize::Locale.instance_variable_set(:@available_messages, {})

    en_available_messages = MessageCustomize::Locale.available_messages('en')
    assert_equal 'am', en_available_messages[:time][:am]
    assert_equal 'Message customize', en_available_messages[:label_custom_messages] # plugin messages
    assert_equal [:en], MessageCustomize::Locale.instance_variable_get(:@available_messages).keys

    # Language 'ja' not loaded
    ja_available_messages = MessageCustomize::Locale.available_messages('ja')
    assert_equal "午前", ja_available_messages[:time][:am]
    assert_equal 'メッセージのカスタマイズ', ja_available_messages[:label_custom_messages] # plugin messages
    assert_equal [:en, :ja], MessageCustomize::Locale.instance_variable_get(:@available_messages).keys
  end

  def test_available_messages_should_return_messages_without_plugin_messages_if_not_customizable_plugin_messages
    MessageCustomize::Locale.stubs(:customizable_plugin_messages?).returns(false)

    # Reset @available_messages
    MessageCustomize::Locale.instance_variable_set(:@available_messages, {})

    en_available_messages = MessageCustomize::Locale.available_messages('en')
    assert_equal 'am', en_available_messages[:time][:am]
    assert_nil en_available_messages[:label_custom_messages] # plugin messages
    assert_equal [:en], MessageCustomize::Locale.instance_variable_get(:@available_messages).keys

    # Language 'ja' not loaded
    ja_available_messages = MessageCustomize::Locale.available_messages('ja')
    assert_equal "午前", ja_available_messages[:time][:am]
    assert_nil ja_available_messages[:label_custom_messages] # plugin messages
    assert_equal [:en, :ja], MessageCustomize::Locale.instance_variable_get(:@available_messages).keys
  end

  def test_customizable_plugin_messages?
    expect = File.exist?(Rails.root.join('config', 'initializers', MessageCustomize::Locale::CHANGE_LOAD_ORDER_LOCALES_FILE_PATH))
    assert_equal expect, MessageCustomize::Locale.customizable_plugin_messages?
  end
end
