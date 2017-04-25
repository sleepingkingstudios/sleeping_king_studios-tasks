# lib/sleeping_king_studios/tasks/apps/ci/rubocop.rb

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/steps'

module SleepingKingStudios::Tasks::Apps::Ci
  # Defines a Thor task for running the RuboCop linter for each application.
  class RuboCop < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the RuboCop linter for each application.'
    end # class method description

    def self.task_name
      'rubocop'
    end # class method task_name

    option :quiet,
      :aliases => '-q',
      :type    => :boolean,
      :default => false,
      :desc    => 'Do not write lint results to STDOUT.'

    def call *applications
      SleepingKingStudios::Tasks::Apps::Ci::Steps.
        new(options.merge('only' => %w(rubocop))).
        call(*applications)
    end # method call
  end # class
end # module
