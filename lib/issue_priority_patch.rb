require_dependency 'issue_priority'

module CustomMessages
  module IssuePriorityPatch
    def name
      l("custom_object_name.issue_priority_#{self.id}", {default: super, fallback: false})
    end
  end
end

unless IssuePriority.included_modules.include?(CustomMessages::IssuePriorityPatch)
  IssuePriority.prepend(CustomMessages::IssuePriorityPatch)
end