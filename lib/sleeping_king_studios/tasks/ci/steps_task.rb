# lib/sleeping_king_studios/tasks/ci/steps_task.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/results_helpers'
require 'sleeping_king_studios/tasks/ci/steps_runner'

module SleepingKingStudios::Tasks::Ci
  # Thor task for running each step in the CI suite and generating a report.
  class StepsTask < SleepingKingStudios::Tasks::Ci::StepsRunner
    include SleepingKingStudios::Tasks::Ci::ResultsHelpers

    def self.description
      'Runs the configured steps for your test suite.'
    end # class method description

    option :except,
      :type    => :array,
      :default => [],
      :desc    => 'Exclude steps from the CI process.'
    option :only,
      :type    => :array,
      :default => [],
      :desc    => 'Run only the specified steps from the CI process.'
    option :quiet,
      :aliases => '-q',
      :type    => :boolean,
      :default => false,
      :desc    => 'Do not write intermediate results to STDOUT.'

    def call *files
      results = super

      report results

      report_failures results

      results
    end # method call

    private

    def ci_steps
      SleepingKingStudios::Tasks.configuration.ci.steps_with_options
    end # method ci_steps

    def failing? step
      return true if step.failing?

      return true if step.respond_to?(:errored?) && step.errored?

      false
    end # method failing?

    def format_failures failing_steps
      tools.array.humanize_list(failing_steps) do |name|
        set_color(name, :red)
      end # humanize list
    end # method format_failures

    def report results
      rows =
        results.map do |key, obj|
          [set_color("#{key}:", results_color(obj)), obj.to_s]
        end # results

      say "\n"

      print_table rows
    end # method report

    # rubocop:disable Metrics/MethodLength
    def report_failures results
      failing_steps =
        results.each.with_object([]) do |(key, step), ary|
          ary << key if failing?(step)
        end # each

      say "\n"

      if failing_steps.empty?
        say 'The CI suite passed.', :green

        return
      end # if

      say "The following steps failed: #{format_failures failing_steps}"
      say "\n"

      raise Thor::Error, 'The CI suite failed.'
    end # method report_failures
    # rubocop:enable Metrics/MethodLength
  end # class
end # module
