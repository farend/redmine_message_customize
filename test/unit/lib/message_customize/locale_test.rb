require File.expand_path('../../../../test_helper', __FILE__)

class LocaleTest < ActiveSupport::TestCase
  fixtures :custom_message_settings
  include Redmine::I18n

  def test_reload!
    setting = CustomMessageSetting.find(1)
    setting.value = {custom_messages: { 'en' => { 'label_home' => 'Changed home' }}}
    setting.save

    assert_equal 'Home1', I18n.backend.send(:translations)[:en][:label_home]
    MessageCustomize::Locale.reload!(['en'])
    assert_equal 'Changed home', I18n.backend.send(:translations)[:en][:label_home]
  end

  # If this test fails:
  #  Check if you need to change plugins/redmine_message_customize/config/locales/custom_messages.
  def test_available_locales
    locales = %w[ar az bg bs ca cs da de el en en-GB es es-PA et eu fa fi fr gl he hr hu id it ja ko lt lv mk mn nl no pl pt pt-BR ro ru sk sl sq sr sr-YU sv th tr uk vi zh zh-TW]
    assert_equal locales.uniq.sort.map(&:to_sym), MessageCustomize::Locale.available_locales
  end
end
