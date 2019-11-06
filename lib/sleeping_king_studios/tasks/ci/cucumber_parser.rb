# lib/sleeping_king_studios/tasks/ci/cucumber_parser.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Parses the output from cucumber --format=json into a summary report.
  module CucumberParser
    class << self
      def parse results
        @report = build_report

        results.each { |feature| parse_feature(feature) }

        report['duration'] = report['duration'] / (1.0 * 10**9)

        report
      end # class method parse

      private

      attr_reader :report

      def build_report
        {
          'scenario_count'     => 0,
          'failing_scenarios'  => [],
          'pending_scenarios'  => [],
          'step_count'         => 0,
          'failing_step_count' => 0,
          'pending_step_count' => 0,
          'duration'           => 0
        } # end report
      end # method build report

      def parse_feature feature
        feature['elements'].each do |scenario|
          parse_scenario(scenario, feature)
        end # each
      end # method parse_feature

      # rubocop:disable Metrics/MethodLength
      def parse_scenario scenario, feature
        failing = false
        pending = false

        scenario['steps'].each do |step|
          status = parse_step(step)

          failing ||= status == 'failed'
          pending ||= status == 'pending' || status == 'skipped'
        end # each

        report_scenario(
          scenario,
          feature,
          :failing => failing,
          :pending => pending
        ) # end report scenario
      end # method parse_scenario
      # rubocop:enable Metrics/MethodLength

      def parse_step step
        report['step_count'] += 1
        report['duration']   += step_duration(step)

        status = step_status(step) || 'failed'

        case status
        when 'failed'
          report['failing_step_count'] += 1
        when 'pending', 'skipped'
          report['pending_step_count'] += 1
        end

        status
      end # method parse_step

      # rubocop:disable Metrics/MethodLength
      def report_scenario scenario, feature, failing:, pending:
        report['scenario_count'] += 1

        return unless failing || pending

        hsh =
          {
            'location' => "#{feature['uri']}:#{scenario['line']}",
            'description' => "#{scenario['keyword']}: #{scenario['name']}"
          }

        if failing
          report['failing_scenarios'] << hsh
        else
          report['pending_scenarios'] << hsh
        end # if-else
      end # method report_scenario
      # rubocop:enable Metrics/MethodLength

      def step_duration hsh
        return 0 if hsh.nil? || hsh.empty?

        result = hsh['result']

        return 0 if result.nil? || result.empty?

        result['duration'] || 0
      end # method step_duration

      def step_status hsh
        return nil if hsh.nil? || hsh.empty?

        result = hsh['result']

        return nil if result.nil? || result.empty?

        result['status']
      end # method step_status
    end # class
  end # module
end # module
