# lib/sleeping_king_studios/tasks/ci/rspec.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/rspec_results'
require 'sleeping_king_studios/tasks/ci/rspec_runner'

module SleepingKingStudios::Tasks::Ci
  # Defines a Thor task for running the full RSpec test suite.
  class RSpec < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the RSpec test suite.'
    end # class method description

    def self.task_name
      :rspec
    end # class method task_name

    option :coverage,
      :type    => :boolean,
      :desc    => 'Enable or disable coverage with SimpleCov, if available.'
    option :gemfile,
      :type    => :string,
      :desc    => 'The Gemfile used to run the specs.'
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
      results = rspec_runner(files.empty?).call(:files => files)

      raw? ? results : RSpecResults.new(results)
    end # method call

    private

    def rspec_runner default_coverage = true
      coverage = options.fetch('coverage', default_coverage)

      env = options.fetch('__env__', {})
      env[:bundle_gemfile] = gemfile if gemfile
      env[:coverage]       = false unless coverage

      opts = %w(--color --tty)
      opts << '--format=documentation' unless quiet?

      RSpecRunner.new(:env => env, :options => opts)
    end # method rspec_runner
  end # class
end # module
