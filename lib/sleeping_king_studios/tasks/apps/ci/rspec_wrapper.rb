# lib/sleeping_king_studios/tasks/apps/ci/rspec_wrapper.rb

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/step_wrapper'
require 'sleeping_king_studios/tasks/ci/rspec_results'

module SleepingKingStudios::Tasks::Apps::Ci
  # Wrapper class for calling an RSpec Ci task for a specific application.
  class RSpecWrapper < SleepingKingStudios::Tasks::Apps::Ci::StepWrapper
    def call application
      super

      if spec_files.empty?
        return SleepingKingStudios::Tasks::Ci::RSpecResults.new({})
      end # if

      run_step(*spec_files)
    end # method call

    private

    def spec_files
      SleepingKingStudios::Tasks::Apps.
        configuration[current_application].
        spec_files
    end # method spec_files

    def step_key
      :rspec
    end # method step_key

    def step_options
      gemfile = applications[current_application].fetch('gemfile', 'Gemfile')

      super.merge(
        'coverage' => true,
        'gemfile'  => gemfile,
        '__env__'  => { :app_name => current_application }
      ) # end merge
    end # method step_options
  end # class
end # module
