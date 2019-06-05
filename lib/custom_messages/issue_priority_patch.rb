require_dependency 'issue_priority'

module CustomMessages
  module IssuePriorityPatch
    extend ActiveSupport::Concern
    def name
      l("custom_object_name.issue_priority_#{self.id}", {default: super, fallback: false})
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  unless IssuePriority.included_modules.include?(CustomMessages::IssuePriorityPatch)
    IssuePriority.prepend(CustomMessages::IssuePriorityPatch)
  end
end
