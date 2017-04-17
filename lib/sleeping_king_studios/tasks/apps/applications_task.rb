# lib/sleeping_king_studios/tasks/apps/applications_task.rb

require 'yaml'

require 'sleeping_king_studios/tasks/apps'

module SleepingKingStudios::Tasks::Apps
  # Task class with additional configuration for performing actions on a
  # per-application basis.
  class ApplicationsTask < SleepingKingStudios::Tasks::Task
    private

    def applications
      @applications ||=
        begin
          raw = File.read(config_file)

          YAML.safe_load raw
        end # applications
    end # method applications

    def config_file
      SleepingKingStudios::Tasks.configuration.apps.config_file
    end # method config_file

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
