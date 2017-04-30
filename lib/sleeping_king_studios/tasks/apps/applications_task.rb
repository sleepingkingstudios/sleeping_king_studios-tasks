# lib/sleeping_king_studios/tasks/apps/applications_task.rb

require 'yaml'

require 'sleeping_king_studios/tasks/apps'

module SleepingKingStudios::Tasks::Apps
  # Extension module with additional configuration for performing actions on a
  # per-application basis.
  module ApplicationsTask
    private

    def applications
      SleepingKingStudios::Tasks::Apps.configuration
    end # method applications

    def filter_applications only: []
      filtered = applications

      if only && !only.empty?
        normalized = only.map(&:to_s)
        filtered   = filtered.select { |key, _| normalized.include?(key) }
      end # if

      filtered
    end # method filter_applications
  end # class
end # module
