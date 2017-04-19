# lib/sleeping_king_studios/tasks/ci/steps.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/results_helpers'

module SleepingKingStudios::Tasks::Ci
  # Thor task for running each step in the CI suite and generating a report.
  class Steps < SleepingKingStudios::Tasks::Task
    include SleepingKingStudios::Tasks::Ci::ResultsHelpers

    def self.description
      'Runs the configured steps for your test suite.'
    end # class method description

    def call *files
      results = {}

      ci_steps.each do |name, config|
        title = config.fetch(:title, name)

        results[title] = call_step(config, files)
      end # reduce

      say "\n"

      report results

      report_failures results
    end # method call

    private

    def ci_steps
      SleepingKingStudios::Tasks.configuration.ci.steps_with_options
    end # method ci_steps

    def call_step config, files
      class_name   = config[:class]
      require_path = config.fetch(:require, require_path(class_name))

      require require_path

      step_class = Object.const_get(class_name)
      instance   = step_class.new(options)

      instance.call(*files)
    end # method call_step

    def format_failures failing_steps
      tools.array.humanize_list(failing_steps) do |name|
        set_color(name, :red)
      end # humanize list
    end # method format_failures

    def report results
      rows =
        results.map do |key, obj|
          [set_color(key, results_color(obj)), obj.to_s]
        end # results

      print_table rows
    end # method report

    # rubocop:disable Metrics/MethodLength
    def report_failures results
      failing_steps =
        results.each.with_object([]) do |(key, obj), ary|
          ary << key if obj.failing?
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

    def require_path class_name
      class_name.
        split('::').
        map { |str| tools.string.underscore(str) }.
        join '/'
    end # method require_path
  end # class
end # module
