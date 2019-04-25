class CustomMessageSettingsController < ApplicationController
  layout 'admin'
  self.main_menu = false
  before_action :require_admin, :set_custom_message_setting, :set_lang
  require_sudo_mode :edit, :update

  def edit
    @lang = params[:lang].presence || User.current.language
  end

  def update
    original_custom_messages = @setting.custom_messages
    languages = (original_custom_messages ? original_custom_messages.keys.map(&:to_s) : [])

    if custom_message_setting_params[:custom_messages]
      messages = original_custom_messages.merge({@lang => CustomMessageSetting.to_nested_hash(custom_message_setting_params[:custom_messages].to_unsafe_h.to_hash) })
    elsif custom_message_setting_params[:custom_messages_yaml]
      messages = custom_message_setting_params[:custom_messages_yaml]
    else
      message = {@lang => {}}
    end
    if @setting.update_custom_messages(messages)
      flash[:notice] = l(:notice_successful_update)
      new_custom_messages = @setting.custom_messages
      if new_custom_messages.present?
        languages += new_custom_messages.keys.map(&:to_s)
        CustomMessageSetting.reload_translations!(languages)
      end
      redirect_to edit_custom_message_settings_path
    else
      @lang ||= User.current.language
      render :edit
    end
  end

  private

  def set_custom_message_setting
    @setting = CustomMessageSetting.find_or_default
  end

  def custom_message_setting_params
    params.fetch(:settings, {}).permit(:custom_messages_yaml, custom_messages: {})
  end

  def set_lang
    @lang = CustomMessageSetting.find_language(params[:lang]) if params[:lang]
  end
end