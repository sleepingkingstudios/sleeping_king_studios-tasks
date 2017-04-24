# lib/sleeping_king_studios/tasks/apps/ci/results_reporter.rb

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/ci/results_helpers'

module SleepingKingStudios::Tasks::Apps::Ci
  # Reports on the results of a multi-application continuous integration
  # process, printing the step results grouped by application.
  class ResultsReporter
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    include SleepingKingStudios::Tasks::Ci::ResultsHelpers

    delegate \
      :applications,
      :print_table,
      :say,
      :set_color,
      :to => :@context

    def initialize context
      @context = context
    end # method initialize

    def call results
      width = 1 + heading_width(results)

      results.each do |application, app_results|
        report_application application, app_results, :width => width
      end # each
    end # method call

    private

    def heading_width results
      results.reduce(0) do |memo, (_, hsh)|
        [memo, *hsh.keys.map(&:size)].max
      end # reduce
    end # method heading_width

    def generate_rows results, width:
      results.map do |key, obj|
        next nil if obj.nil?

        badge = format("  %-#{width}.#{width}s", "#{key}:")

        [set_color(badge, results_color(obj)), obj.to_s]
      end. # rows
        compact
    end # method generate_rows

    def report_application app_name, results, width:
      config   = applications.fetch(app_name, {})
      app_name = config.fetch('name', app_name)
      rows     = generate_rows(results, :width => width)

      return if rows.empty?

      say "#{app_name}:"
      say "\n"

      print_table rows

      say "\n"
    end # method report_application
  end # class
end # module
