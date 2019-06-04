require_dependency 'issue_category'

module CustomMessages
  module IssueCategoryPatch
    def name
      l("custom_object_name.issue_category_#{self.id}", {default: super, fallback: false})
    end
  end
end

unless IssueCategory.included_modules.include?(CustomMessages::IssueCategoryPatch)
  IssueCategory.prepend(CustomMessages::IssueCategoryPatch)
end