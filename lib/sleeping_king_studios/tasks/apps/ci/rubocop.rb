# lib/sleeping_king_studios/tasks/apps/ci/rubocop.rb

require 'sleeping_king_studios/tasks/apps/applications_task'
require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/results_reporter'
require 'sleeping_king_studios/tasks/ci/rubocop_results'
require 'sleeping_king_studios/tasks/ci/rubocop_runner'

module SleepingKingStudios::Tasks::Apps::Ci
  # Defines a Thor task for running the RuboCop linter for each application.
  class RuboCop < SleepingKingStudios::Tasks::Task
    include SleepingKingStudios::Tasks::Apps::ApplicationsTask

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
    option :report,
      :aliases => '-r',
      :type    => :boolean,
      :default => true,
      :desc    => 'Write summary report to STDOUT.'

    def call *applications
      mute! if quiet?

      filtered = filter_applications :only => applications
      results  = run_rubocop(filtered)

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
        rubocop = app_results['RuboCop']

        totals['inspected_file_count'] += rubocop.inspected_file_count
        totals['offense_count']        += rubocop.offense_count
      end # each

      totals = SleepingKingStudios::Tasks::Ci::RuboCopResults.new(totals)

      results['Totals']['RuboCop'] = totals
    end # method aggregate_results

    def rubocop_runner
      opts = %w(--color)
      opts << '--format=progress' unless quiet?

      SleepingKingStudios::Tasks::Ci::RuboCopRunner.new(:options => opts)
    end # method rubocop_runner

    def run_rubocop applications
      results = Hash.new { |hsh, key| hsh[key] = {} }

      applications.each do |name, app|
        next if ci_step_config(name, :rubocop) == false

        results[name]['RuboCop'] = run_rubocop_for_application(name, app)
      end # each

      aggregate_results(results)

      results
    end # method run_rubocop

    def run_rubocop_for_application name, config
      gemfile   = config.fetch('gemfile', 'Gemfile')
      src_files =
        source_files(name, config) +
        spec_directories(name, config)

      say %(\nRunning linter for application "#{name}":)

      env = { :bundle_gemfile => gemfile }

      raw = rubocop_runner.call(:env => env, :files => src_files)

      SleepingKingStudios::Tasks::Ci::RuboCopResults.new(raw)
    end # method run_rspec_for_application
  end # class
end # module
