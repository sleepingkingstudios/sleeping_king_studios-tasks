# lib/sleeping_king_studios/tasks/ci/rubocop.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/rubocop_runner'

module SleepingKingStudios::Tasks::Ci
  # Defines a Thor task for running the RuboCop linter.
  class RuboCop < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the RuboCop linter.'
    end # class method description

    def self.task_name
      :rubocop
    end # class method task_name

    option :quiet,
      :aliases => '-q',
      :type    => :boolean,
      :default => false,
      :desc    => 'Do not write lint results to STDOUT.'

    def call *files
      rubocop_runner.call(:files => files)
    end # method call

    private

    def rubocop_runner
      opts = %w(--color)
      opts << '--format=progress' unless quiet?

      RuboCopRunner.new(:options => opts)
    end # method rubocop_runner
  end # class
end # module
