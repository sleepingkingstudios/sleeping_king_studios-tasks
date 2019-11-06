# lib/sleeping_king_studios/tasks/apps/ci/rspec_task.rb

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/steps_task'

module SleepingKingStudios::Tasks::Apps::Ci
  # Defines a Thor task for running the RSpec test suite for each application.
  class RSpecTask < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the RSpec test suite for each application.'
    end # class method description

    def self.task_name
      'rspec'
    end # class method task_name

    option :quiet,
      :aliases => '-q',
      :type    => :boolean,
      :default => false,
      :desc    => 'Do not write spec results to STDOUT.'

    def call *applications
      SleepingKingStudios::Tasks::Apps::Ci::StepsTask.
        new(options.merge('only' => %w[rspec])).
        call(*applications)
    end # method call
  end # class
end # module
