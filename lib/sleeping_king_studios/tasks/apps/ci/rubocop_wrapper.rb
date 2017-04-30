# lib/sleeping_king_studios/tasks/apps/ci/rubocop_wrapper.rb

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/step_wrapper'
require 'sleeping_king_studios/tasks/ci/rubocop_results'

module SleepingKingStudios::Tasks::Apps::Ci
  # Wrapper class for calling a RuboCop Ci task for a specific application.
  class RuboCopWrapper < SleepingKingStudios::Tasks::Apps::Ci::StepWrapper
    def call application
      super

      run_step(*source_files)
    end # method call

    private

    def source_files
      config =
        SleepingKingStudios::Tasks::Apps.configuration[current_application]

      config.source_files + config.spec_files
    end # method source_files

    def step_key
      :rubocop
    end # method step_key
  end # module
end # module
