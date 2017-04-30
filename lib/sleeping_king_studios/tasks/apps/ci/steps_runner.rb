# lib/sleeping_king_studios/tasks/apps/ci/steps_runner.rb

require 'sleeping_king_studios/tasks/apps/applications_task'
require 'sleeping_king_studios/tasks/ci/steps_runner'

module SleepingKingStudios::Tasks::Apps::Ci
  # Abstract base class for running a sequence of tasks for a specific
  # application from a configured list.
  class StepsRunner < SleepingKingStudios::Tasks::Ci::StepsRunner
    include SleepingKingStudios::Tasks::Apps::ApplicationsTask

    def call application
      @current_application = application

      super application
    end # method call

    private

    attr_reader :current_application

    def ci_steps
      SleepingKingStudios::Tasks::Apps.configuration[current_application].
        ci.steps_with_options
    end # method ci_steps

    def skip_step? _name, config
      return true if config == false

      if options.fetch('global', false)
        !config.fetch(:global, false)
      else
        config.fetch(:global, false)
      end # if-else
    end # method skip_step?
  end # class
end # module
