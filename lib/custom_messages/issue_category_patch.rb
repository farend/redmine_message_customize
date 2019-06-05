require_dependency 'issue_category'

module CustomMessages
  module IssueCategoryPatch
    extend ActiveSupport::Concern
    def name
      l("custom_object_name.issue_category_#{self.id}", {default: super, fallback: false})
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  unless IssueCategory.included_modules.include?(CustomMessages::IssueCategoryPatch)
    IssueCategory.prepend(CustomMessages::IssueCategoryPatch)
  end
end
