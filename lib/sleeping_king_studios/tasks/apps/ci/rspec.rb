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
    option :report,
      :aliases => '-r',
      :type    => :boolean,
      :default => true,
      :desc    => 'Write summary report to STDOUT.'

    def call *applications
      mute! if quiet?

      filtered = filter_applications :only => applications
      results  = run_rspec(filtered)

      return results unless report?

      @mute = false

      reporter = ResultsReporter.new(self)
      reporter.call(results)

      results
    end # method call

    private

    def aggregate_results results
      totals = Hash.new { |hsh, key| hsh[key] = 0 }

      results.each do |_, app_results|
        rspec = app_results['RSpec']
        rspec.to_h.each do |key, value|
          totals[key] += value
        end # each
      end # each

      totals = SleepingKingStudios::Tasks::Ci::RSpecResults.new(totals)

      results['Totals']['RSpec'] = totals
    end # method aggregate_results

    def rspec_runner
      opts = %w(--color --tty)
      opts << '--format=documentation' unless quiet?

      SleepingKingStudios::Tasks::Ci::RSpecRunner.new(:options => opts)
    end # method rspec_runner

    def run_rspec applications
      results = Hash.new { |hsh, key| hsh[key] = {} }

      applications.each do |name, app|
        next if ci_step_config(name, :rspec) == false

        results[name]['RSpec'] = run_rspec_for_application(name, app)
      end # each

      aggregate_results(results)

      results
    end # method run_rspec

    def run_rspec_for_application name, config
      say %(\nRunning specs for application "#{name}":)

      spec_dir = spec_directories(name, config)

      if spec_dir.empty?
        return SleepingKingStudios::Tasks::Ci::RSpecResults.new({})
      end # if

      env = { :bundle_gemfile => config.fetch('gemfile', 'Gemfile') }
      raw = rspec_runner.call(:env => env, :files => spec_dir)

      SleepingKingStudios::Tasks::Ci::RSpecResults.new(raw)
    end # method run_rspec_for_application
  end # class
end # module
