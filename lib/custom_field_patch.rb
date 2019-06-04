require_dependency 'custom_field'

module CustomMessages
  module CustomFieldPatch
    def name
      l("custom_object_name.custom_field_#{self.id}", {default: super, fallback: false})
    end
  end
end

unless CustomField.included_modules.include?(CustomMessages::CustomFieldPatch)
  CustomField.prepend(CustomMessages::CustomFieldPatch)
end