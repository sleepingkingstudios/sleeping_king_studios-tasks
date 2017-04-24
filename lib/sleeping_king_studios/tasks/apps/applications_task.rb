# lib/sleeping_king_studios/tasks/apps/applications_task.rb

require 'yaml'

require 'sleeping_king_studios/tasks/apps'

module SleepingKingStudios::Tasks::Apps
  # Extension module with additional configuration for performing actions on a
  # per-application basis.
  module ApplicationsTask
    private

    def applications
      @applications ||=
        begin
          raw = File.read(config_file)

          YAML.safe_load raw
        end # applications
    end # method applications

    # rubocop:disable Metrics/AbcSize
    def ci_step_config name, step
      default =
        SleepingKingStudios::Tasks.
        configuration.ci.steps_with_options.
        fetch(step.intern)
      config  = applications.fetch(name, {}).fetch('ci', {})[step.to_s]

      return false   if config == false
      return default unless config.is_a?(Hash)

      config  = tools.hash.convert_keys_to_symbols(config)
      updated = tools.hash.deep_dup(default)

      updated.merge(config)
    end # method ci_step_config
    # rubocop:enable Metrics/AbcSize

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

    def source_files name, config
      src_files =
        config.fetch('source_files') do
          ["apps/#{name}.rb", "apps/#{name}", "lib/#{name}.rb", "lib/#{name}"].
            select { |file_name| File.exist?(file_name) }
        end # fetch

      Array(src_files)
    end # method source_files

    def spec_directories name, config
      spec_dir =
        config.fetch('spec_dir') do
          ["spec/#{name}", "apps/#{name}/spec"].
            select { |dir_name| File.directory?(dir_name) }
        end # fetch

      Array(spec_dir)
    end # methodd spec_directories
  end # class
end # module
