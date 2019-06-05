require_dependency 'issue_status'

module CustomMessages
  module IssueStatusPatch
    extend ActiveSupport::Concern
    def name
      l("custom_object_name.issue_status_#{self.id}", {default: super, fallback: false})
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  unless IssueStatus.included_modules.include?(CustomMessages::IssueStatusPatch)
    IssueStatus.prepend(CustomMessages::IssueStatusPatch)
  end
end
