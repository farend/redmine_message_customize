require_dependency 'tracker'

module CustomMessages
  module TrackerPatch
    extend ActiveSupport::Concern
    def name
      l("custom_object_name.tracker_#{self.id}", {default: super, fallback: false})
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  unless Tracker.included_modules.include?(CustomMessages::TrackerPatch)
    Tracker.prepend(CustomMessages::TrackerPatch)
  end
end
