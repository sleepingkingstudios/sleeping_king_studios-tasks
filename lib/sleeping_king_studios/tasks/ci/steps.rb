# lib/sleeping_king_studios/tasks/ci/steps.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/rspec'
require 'sleeping_king_studios/tasks/ci/rubocop'
require 'sleeping_king_studios/tasks/ci/simplecov'

module SleepingKingStudios::Tasks::Ci
  # Thor task for running each step in the CI suite and generating a report.
  class Steps < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the configured steps for your test suite.'
    end # class method description

    def call *files
      results = {}
      results['RSpec']     =
        SleepingKingStudios::Tasks::Ci::RSpec.new(options).call(*files)
      results['RuboCop']   =
        SleepingKingStudios::Tasks::Ci::RuboCop.new(options).call(*files)
      results['SimpleCov'] =
        SleepingKingStudios::Tasks::Ci::SimpleCov.new(options).call(*files)

      say "\n"

      report results

      report_failures results
    end # method call

    private

    def color_heading str, obj
      color =
        if obj.failing?
          :red
        elsif obj.pending? || obj.empty?
          :yellow
        else
          :green
        end # if-else

      set_color("#{str}:", color)
    end # method color_heading

    def format_failures failing_steps
      tools.array.humanize_list(failing_steps) do |name|
        set_color(name, :red)
      end # humanize list
    end # method format_failures

    def report results
      rows =
        results.map { |key, obj| [color_heading(key, obj), obj.to_s] }

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
  end # class
end # module
