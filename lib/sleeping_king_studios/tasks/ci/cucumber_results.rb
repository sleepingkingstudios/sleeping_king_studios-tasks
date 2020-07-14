# lib/sleeping_king_studios/tasks/ci/cucumber_results.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # rubocop:disable Metrics/ClassLength

  # Encapsulates the results of a Cucumber call.
  class CucumberResults
    # @param results [Hash] The raw results of the RSpec call.
    def initialize results
      @results = results
    end # constructor

    # @param other [RSpecResults] The other results object to compare.
    #
    # @return [Boolean] True if the results are equal, otherwise false.
    def == other
      if other.is_a?(Hash)
        empty? ? other.empty? : to_h == other
      elsif other.is_a?(CucumberResults)
        to_h == other.to_h
      else
        false
      end # if-elsif-else
    end # method ==

    # @return [Float] The duration value.
    def duration
      @results.fetch('duration', 0.0)
    end # method duration

    # @return [Boolean] True if there are no scenarios, otherwise false.
    def empty?
      scenario_count.zero?
    end # method empty?

    # @return [Boolean] True if there are any failing scenarios, otherwise
    #   false.
    def failing?
      !failing_scenario_count.zero?
    end # method failing?

    # @return [Integer] The list of failing scenarios.
    def failing_scenarios
      @results.fetch('failing_scenarios', [])
    end # method failing_scenarios

    # @return [Integer] The number of failing scenarios.
    def failing_scenario_count
      failing_scenarios.count
    end # method failing_scenario_count

    # @return [Integer] The number of failing steps.
    def failing_step_count
      @results.fetch('failing_step_count', 0)
    end # method failing_step_count

    # Adds the given result values and returns a new results object with the
    # sums.
    #
    # @param other [RSpecResults] The results to add.
    #
    # @return [RSpecResults] The total results.
    def merge other
      merged = {}

      keys.each do |key|
        merged[key] = public_send(key) + other.public_send(key)
      end # each

      self.class.new(merged)
    end # method merge

    # @return [Boolean] True if there are any pending scenarios, otherwise
    #   false.
    def pending?
      !pending_scenario_count.zero?
    end # method pending?

    # @return [Integer] The number of pending scenarios.
    def pending_scenario_count
      pending_scenarios.count
    end # method pending_scenario_count

    # @return [Integer] The list of pending scenarios.
    def pending_scenarios
      @results.fetch('pending_scenarios', [])
    end # method pending_scenarios

    # @return [Integer] The number of pending steps.
    def pending_step_count
      @results.fetch('pending_step_count', 0)
    end # method pending_step_count

    # @return [Integer] The total number of scenarios.
    def scenario_count
      @results.fetch('scenario_count', 0)
    end # method scenario_count

    # @return [String] A brief summary of the scenario results.
    def scenarios_summary
      build_summary(
        'scenario',
        scenario_count,
        failing_scenario_count,
        pending_scenario_count
      ) # end build_summary
    end # method scenarios_summary

    # @return [Integer] The total number of steps.
    def step_count
      @results.fetch('step_count', 0)
    end # method step_count

    # @return [String] A brief summary of the scenario results.
    def steps_summary
      build_summary(
        'step',
        step_count,
        failing_step_count,
        pending_step_count
      ) # end build_summary
    end # method steps_summary

    # @return [String] A brief summary of the results.
    def summary
      str = scenarios_summary

      str << ', '

      str << steps_summary

      str << " in #{duration.round(2)} seconds"
    end # method summary
    alias_method :to_s, :summary

    # @return [Hash] The hash representation of the results.
    def to_h
      hsh = {}

      keys.each { |key| hsh[key] = public_send(key) }

      hsh
    end # method to_h

    private

    def build_summary name, count, failing_count, pending_count
      str = pluralize(count, name)

      return str if failing_count.zero? && pending_count.zero?

      str << build_summary_details(failing_count, pending_count)
    end # method build_summary

    def build_summary_details failing_count, pending_count
      str = ' ('

      str << pluralize(failing_count, 'failure') unless failing_count.zero?

      str << ', ' if !failing_count.zero? && !pending_count.zero?

      str << "#{pending_count} pending" unless pending_count.zero?

      str << ')'
    end # method build_summary_details

    def keys
      %w[
        duration
        step_count
        pending_step_count
        failing_step_count
        scenario_count
        pending_scenarios
        failing_scenarios
      ] # end keys
    end # method keys

    def pluralize count, singular, plural = nil
      "#{count} #{tools.int.pluralize count, singular, plural}"
    end # method pluralize

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class

  # rubocop:enable Metrics/ClassLength
end # module
