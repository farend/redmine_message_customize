require_dependency 'tracker'

module CustomMessages
  module TrackerPatch
    def name
      l("custom_object_name.tracker_#{self.id}", {default: super, fallback: false})
    end
  end
end

unless Tracker.included_modules.include?(CustomMessages::TrackerPatch)
  Tracker.prepend(CustomMessages::TrackerPatch)
end