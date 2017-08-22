require 'json'

module Bicho
  # Utility methods for exporting bugs to other systems
  module Export
    # Exports full data of a bug to json, including some extended
    # calculated attributes.
    def self.to_json(bug)
      bug_h = bug.to_h
      bug_h['history'] = bug.history.changesets.map(&:to_h)
      bug_h['resolution_time'] = Bicho::Reports.resolution_time(bug)
      JSON.generate(bug_h)
    end
  end
end
