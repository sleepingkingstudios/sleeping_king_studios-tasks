# lib/sleeping_king_studios/tasks/apps/ci/steps.rb

require 'sleeping_king_studios/tasks/apps/applications_task'
require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/results_reporter'
require 'sleeping_king_studios/tasks/apps/ci/steps_runner'

module SleepingKingStudios::Tasks::Apps::Ci
  # Thor task for running each step in the CI suite for each application and
  # generating a report.
  class Steps < SleepingKingStudios::Tasks::Task
    include SleepingKingStudios::Tasks::Apps::ApplicationsTask

    def self.description
      'Runs the configured steps for each application.'
    end # class method description

    option :except,
      :type    => :array,
      :default => [],
      :desc    => 'Exclude steps from the CI process.'
    option :only,
      :type    => :array,
      :default => [],
      :desc    => 'Run only the specified steps from the CI process.'

    def call *applications
      filtered = filter_applications :only => applications
      results  = run_steps(filtered)
      globals  = run_global_steps

      aggregate_results(results) if filtered.count > 1

      (results['Totals'] ||= {}).update(globals)

      reporter = ResultsReporter.new(self)
      reporter.call(results)

      results
    end # method call

    private

    def aggregate_results results
      totals = Hash.new { |hsh, key| hsh[key] = 0 }

      results.each do |_, app_results|
        app_results.each do |step, step_results|
          next if step_results.nil?

          next totals[step] = step_results unless totals.key?(step)

          totals[step] = totals[step].merge(step_results)
        end # each
      end # each

      results['Totals'] = totals
    end # method aggregate_results

    def run_global_steps
      opts   = options.merge 'global' => true
      runner = SleepingKingStudios::Tasks::Apps::Ci::StepsRunner.new(opts)

      runner.call(nil)
    end # method run_global_steps

    def run_steps applications
      results = Hash.new { |hsh, key| hsh[key] = {} }

      applications.each do |name, _|
        results[name] = run_steps_for_application(name)
      end # each

      results
    end # method run_steps

    def run_steps_for_application name
      steps_runner.call(name)
    end # method run_steps_for_application

    def steps_runner
      SleepingKingStudios::Tasks::Apps::Ci::StepsRunner.new(options)
    end # method steps_runner
  end # class
end # module
