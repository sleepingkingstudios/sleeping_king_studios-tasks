# lib/sleeping_king_studios/tasks/ci/steps_runner.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Abstract base class for running a sequence of tasks from a configured list.
  class StepsRunner < SleepingKingStudios::Tasks::Task
    def call *args
      results = {}

      filtered_steps.each do |name, config|
        next if skip_step?(name, config)

        title = config.fetch(:title, name)

        results[title] = call_step(config, args)
      end # reduce

      results
    end # method call

    private

    def ci_steps
      []
    end # method ci_steps

    def call_step config, args
      class_name   = config[:class]
      require_path = config.fetch(:require, require_path(class_name))

      require require_path if require_path

      step_class = Object.const_get(class_name)
      instance   = step_class.new(options)

      instance.call(*args)
    end # method call_step

    # rubocop:disable Metrics/AbcSize
    def filtered_steps
      filtered = ci_steps

      if options.key?('except') && !options['except'].empty?
        filtered =
          filtered.reject { |key, _| options['except'].include?(key.to_s) }
      end # if

      if options.key?('only') && !options['only'].empty?
        filtered =
          filtered.select { |key, _| options['only'].include?(key.to_s) }
      end # if

      filtered
    end # method filtered_steps
    # rubocop:enable Metrics/AbcSize

    def require_path class_name
      class_name.
        split('::').
        map { |str| tools.str.underscore(str) }.
        join '/'
    end # method require_path

    def skip_step? _name, _config
      false
    end # method skip_step?
  end # class
end # module
