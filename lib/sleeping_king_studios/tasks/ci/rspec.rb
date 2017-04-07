# lib/sleeping_king_studios/tasks/ci/rspec.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/rspec_runner'

module SleepingKingStudios::Tasks::Ci
  # Defines a Thor task for running the full RSpec test suite.
  class RSpec < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the RSpec test suite.'
    end # class method description

    def self.task_name
      :rspec
    end # clas method task_name

    option :quiet,
      :aliases => '-q',
      :type    => :boolean,
      :default => false

    def call *files
      rspec_runner.call(:files => files)
    end # method call

    private

    def rspec_runner
      opts = %w(--color --tty)
      opts << '--format=documentation' unless quiet?

      RSpecRunner.new(:options => opts)
    end # method rspec_runner
  end # class
end # module
