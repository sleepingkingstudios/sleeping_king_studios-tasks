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

    def step_config
      config = SleepingKingStudios::Tasks.configuration
      steps  = config.ci.steps_with_options

      steps.fetch(step_key, false)
    end # method step_config

    def step_options
      options
    end # method step_options
  end # class
end # module
