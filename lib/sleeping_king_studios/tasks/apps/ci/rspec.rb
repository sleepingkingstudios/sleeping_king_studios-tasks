# lib/sleeping_king_studios/tasks/apps/ci/rspec.rb

require 'sleeping_king_studios/tasks/apps/applications_task'
require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/results_reporter'
require 'sleeping_king_studios/tasks/ci/results_helpers'
require 'sleeping_king_studios/tasks/ci/rspec_results'
require 'sleeping_king_studios/tasks/ci/rspec_runner'

module SleepingKingStudios::Tasks::Apps::Ci
  # Defines a Thor task for running the RSpec test suite for each application.
  class RSpec < SleepingKingStudios::Tasks::Apps::ApplicationsTask
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
      mute! if quiet?

      filtered = filter_applications :only => applications
      results  = Hash.new { |hsh, key| hsh[key] = {} }

      filtered.each do |name, app|
        results[name]['RSpec'] = run_rspec_for_application(name, app)
      end # each

      totals = aggregate_results(results)
      results['Totals']['RSpec'] = totals

      reporter = ResultsReporter.new(self)
      reporter.call(results)
    end # method call

    private

    def aggregate_results results
      totals = Hash.new { |hsh, key| hsh[key] = 0 }

      results.each do |_, app_results|
        rspec = app_results['RSpec']

        totals['duration']      += rspec.duration
        totals['example_count'] += rspec.example_count
        totals['failure_count'] += rspec.failure_count
        totals['pending_count'] += rspec.pending_count
      end # each

      SleepingKingStudios::Tasks::Ci::RSpecResults.new(totals)
    end # method aggregate_results

    def rspec_runner
      opts = %w(--color --tty)
      opts << '--format=documentation' unless quiet?

      SleepingKingStudios::Tasks::Ci::RSpecRunner.new(:options => opts)
    end # method rspec_runner

    def run_rspec_for_application name, config
      gemfile  = config.fetch('gemfile', 'Gemfile')
      spec_dir = spec_directories(name, config)

      say %(\nRunning specs for application "#{name}":)

      env = { :bundle_gemfile => gemfile }

      raw = rspec_runner.call(:env => env, :files => spec_dir)

      SleepingKingStudios::Tasks::Ci::RSpecResults.new(raw)
    end # method run_rspec_for_application
  end # class
end # module
