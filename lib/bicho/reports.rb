# frozen_string_literal: true

module Bicho
  # Utility methods for reporting on bugs
  module Reports
    # When was the bug finally set to a resolved state
    #
    # Resolution time is nil if the bug is not resolved yet.
    def self.resolution_time(bug)
      t = nil
      bug.history.sort_by(&:timestamp).each do |cs|
        cs.changes.each do |c|
          t = cs.timestamp if c.field_name == 'status' &&
                              c.added == 'RESOLVED'
        end
      end
      t
    end

    # returns the ranges a bug is with statuses
    def self.ranges_with_statuses(bug, *statuses)
      ranges = []
      current_start = bug.creation_time
      current_status = nil
      bug.history.sort_by(&:timestamp).each do |cs|
        cs.changes.each do |c|
          next unless c.field_name == 'status'

          current_status = c.removed if current_status.nil?
          ranges.push(current_start..cs.timestamp) if statuses.include?(c.removed)

          current_start = cs.timestamp
          current_status = c.added
        end
      end
      # last status is still valid
      ranges.push(current_start..Time.now) if statuses.include?(current_status)
      ranges
    end
  end
end
