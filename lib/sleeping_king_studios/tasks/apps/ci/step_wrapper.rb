# lib/sleeping_king_studios/tasks/apps/ci/step_wrapper.rb

require 'sleeping_king_studios/tasks/apps/applications_task'
require 'sleeping_king_studios/tasks/apps/ci'

module SleepingKingStudios::Tasks::Apps::Ci
  # Wrapper class for calling a configured task for a specific application.
  class StepWrapper < SleepingKingStudios::Tasks::Task
    include SleepingKingStudios::Tasks::Apps::ApplicationsTask

    def call application, *_rest
      @current_application = application
      @step_config         = nil
    end # method call

    private

    attr_reader :current_application

    def build_step
      require step_config.fetch(:require) if step_config.key?(:require)

      step_class = Object.const_get(step_config.fetch :class)

      step_class.new(step_options)
    end # method

    def run_step *args
      return if skip_step?

      build_step.call(*args)
    end # method run_step

    def skip_step?
      step_config == false
    end # method skip_step?

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def step_config
      return @step_config unless @step_config.nil?

      default =
        SleepingKingStudios::Tasks.
        configuration.ci.steps_with_options.
        fetch(step_key)
      config  =
        applications.
        fetch(current_application, {}).
        fetch('ci', {})[step_key.to_s]

      return false   if config == false
      return default unless config.is_a?(Hash)

      config  = tools.hash.convert_keys_to_symbols(config)
      updated = tools.hash.deep_dup(default)

      @step_config = updated.merge(config)
    end # method step_config
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def step_options
      options
    end # method step_options
  end # class
end # module
