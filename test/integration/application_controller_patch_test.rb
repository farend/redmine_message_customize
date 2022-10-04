# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class ApplicationControllerPatchTest < Redmine::IntegrationTest
  fixtures :users, :email_addresses, :roles, :custom_message_settings

  def setup
    MessageCustomize::Locale.reload!(['ja', 'en'])
    Rails.application.config.i18n.load_path = (Rails.application.config.i18n.load_path + Dir.glob(Rails.root.join('plugins', 'redmine_message_customize', 'config', 'locales', 'custom_messages', '*.rb'))).uniq
  end

  def test_reload_if_messages_are_not_latest
    User.find_by_login('admin').update(language: 'ja')
    log_user('admin', 'admin')
    custom_message_setting = CustomMessageSetting.find_or_default

    # 値が書き換わっただけでは用語は置き換わらない(MessageCustomize::Locale.reload!の実行が必要)
    custom_message_setting.update_with_custom_messages({'label_home' => 'Changed home'}, 'ja')
    assert_equal 'Home2', I18n.backend.send(:translations)[:ja][:label_home]
    assert_equal '1640995200', I18n.backend.send(:translations)[:ja][:redmine_message_customize_timestamp]

    # ApplicationControllerのbefore_actionによって、redmine_message_customize_timestampの値を見て最新かが判断される
    # get '/issues'は最新じゃない状態でのリクエストのためMessageCustomize::Locale.reload!が実行されること
    get '/issues'
    assert_equal 'Changed home', I18n.backend.send(:translations)[:ja][:label_home]
    assert_equal custom_message_setting.updated_on.to_i.to_s, I18n.backend.send(:translations)[:ja][:redmine_message_customize_timestamp]
  end

  def test_reload_if_user_language_is_auto_and_default_language_messages_are_not_latest
    # User.currentのlanguageが''(auto)でもSetting.default_languageを元に用語の最新化を行うこと
    User.find_by_login('admin').update(language: '')
    Setting.default_language = 'ja'
    log_user('admin', 'admin')
    custom_message_setting = CustomMessageSetting.find_or_default

    custom_message_setting.update_with_custom_messages({'label_home' => 'Changed home'}, 'ja')
    assert_equal 'Home2', I18n.backend.send(:translations)[:ja][:label_home]
    assert_equal '1640995200', I18n.backend.send(:translations)[:ja][:redmine_message_customize_timestamp]

    get '/issues'
    assert_equal 'Changed home', I18n.backend.send(:translations)[:ja][:label_home]
    assert_equal custom_message_setting.updated_on.to_i.to_s, I18n.backend.send(:translations)[:ja][:redmine_message_customize_timestamp]
  end

  def test_reload_if_messages_are_in_different_language_than_the_language_in_which_you_customized_the_message
    # メッセージをカスタマイズした言語とは別の言語を利用している場合もreloadすること
    User.find_by_login('admin').update(language: 'en')
    log_user('admin', 'admin')
    custom_message_setting = CustomMessageSetting.find_or_default

    custom_message_setting.update_with_custom_messages({'label_home' => 'Changed home'}, 'ja')
    assert_equal 'Home1', I18n.backend.send(:translations)[:en][:label_home]
    assert_equal '1640995200', I18n.backend.send(:translations)[:en][:redmine_message_customize_timestamp]

    get '/issues'
    assert_equal 'Home1', I18n.backend.send(:translations)[:en][:label_home] # 変わらない
    assert_equal custom_message_setting.updated_on.to_i.to_s, I18n.backend.send(:translations)[:en][:redmine_message_customize_timestamp]
  end

  def test_dont_reload_if_messages_are_latest
    MessageCustomize::Locale.expects(:reload!).never
    get '/issues'
  end

  def test_dont_reload_if_customize_message_setting_is_not_saved
    CustomMessageSetting.find_or_default.destroy

    MessageCustomize::Locale.expects(:reload!).never
    get '/issues'
  end
end
