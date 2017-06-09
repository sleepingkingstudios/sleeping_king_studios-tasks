# lib/sleeping_king_studios/tasks/ci/cucumber_task.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/cucumber_results'
require 'sleeping_king_studios/tasks/ci/cucumber_runner'

module SleepingKingStudios::Tasks::Ci
  # Defines a Thor task for running the full RSpec test suite.
  class CucumberTask < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the Cucumber feature suite.'
    end # class method description

    option :quiet,
      :aliases => '-q',
      :type    => :boolean,
      :default => false,
      :desc    => 'Do not write spec results to STDOUT.'
    option :raw,
      :aliases => '-r',
      :type    => :boolean,
      :default => false,
      :desc    => 'Return a Hash instead of a results object.'

    def call *files
      files += default_files unless files.empty?

      results = cucumber_runner.call(:files => files)

      raw? ? results : CucumberResults.new(results)
    end # method call

    private

    def cucumber_runner
      opts = %w(--color)
      opts << '--format=pretty' unless quiet?

      CucumberRunner.new(:options => opts)
    end # method cucumber_runner

    def default_files
      SleepingKingStudios::Tasks.configuration.ci.cucumber.
        fetch('default_files', [])
    end # method default_files
  end # class
end # module
