# lib/sleeping_king_studios/tasks/ci/steps.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Thor task for running each step in the CI suite and generating a report.
  class Steps < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the configured steps for your test suite.'
    end # class method description

    def call *files
      results = {}

      ci_steps.each do |name, config|
        results[name] = call_step(config, files)
      end # reduce

      say "\n"

      report results

      report_failures results
    end # method call

    private

    # rubocop:disable Metrics/MethodLength
    def ci_steps
      {
        'RSpec' => {
          :require => 'sleeping_king_studios/tasks/ci/rspec',
          :class   => 'SleepingKingStudios::Tasks::Ci::RSpec'
        }, # end RSpec
        'RuboCop' => {
          :require => 'sleeping_king_studios/tasks/ci/rubocop',
          :class   => 'SleepingKingStudios::Tasks::Ci::RuboCop'
        }, # end RuboCop
        'SimpleCov' => {
          :require => 'sleeping_king_studios/tasks/ci/simplecov',
          :class   => 'SleepingKingStudios::Tasks::Ci::SimpleCov'
        } # end SimpleCov
      } # end steps
    end # method ci_steps
    # rubocop:enable Metrics/MethodLength

    def call_step config, files
      class_name   = config[:class]
      require_path = config.fetch(:require, require_path(class_name))

      require require_path

      step_class = Object.const_get(class_name)
      instance   = step_class.new(options)

      instance.call(*files)
    end # method call_step

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

    def require_path class_name
      class_name.
        split('::').
        map { |str| tools.string.underscore(str) }.
        join '/'
    end # method require_path
  end # class
end # module
