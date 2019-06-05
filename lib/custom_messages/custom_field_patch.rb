require_dependency 'custom_field'

module CustomMessages
  module CustomFieldPatch
    extend ActiveSupport::Concern
    def name
      l("custom_object_name.custom_field_#{self.id}", {default: super, fallback: false})
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  unless CustomField.included_modules.include?(CustomMessages::CustomFieldPatch)
    CustomField.prepend(CustomMessages::CustomFieldPatch)
  end
end
