require_dependency 'issue_status'

module CustomMessages
  module IssueStatusPatch
    def name
      l("custom_object_name.issue_status_#{self.id}", {default: super, fallback: false})
    end
  end
end

unless IssueStatus.included_modules.include?(CustomMessages::IssueStatusPatch)
  IssueStatus.prepend(CustomMessages::IssueStatusPatch)
end