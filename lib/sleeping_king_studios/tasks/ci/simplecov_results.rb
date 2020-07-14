# lib/sleeping_king_studios/tasks/ci/simplecov_results.rb

require 'forwardable'

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Encapsulates the results of aggregated SimpleCov data.
  class SimpleCovResults
    extend Forwardable

    # @param results [SimpleCov::Result] The raw results of the SimpleCov call.
    def initialize results
      @results = results
    end # constructor

    def_delegators :@results,
      :covered_lines,
      :covered_percent,
      :missed_lines,
      :total_lines

    # @return [Boolean] True if there are no covered lines, otherwise false.
    def empty?
      covered_lines.zero?
    end # method empty?

    # @return [Boolean] True if the covered percentage is less than or equal to
    #   the configured value, otherwise false.
    def failing?
      covered_percent.round(1) <= failing_percent.round(1)
    end # method failing?

    # @return [Float] If the covered percentage is less than or equal to this
    #   value, the result is failing.
    def failing_percent
      90.0
    end # method failing_percent

    # @return [Boolean] True if the covered percentage is less than or equal to
    #   the configured value, otherwise false.
    def pending?
      !failing? && covered_percent.round(1) <= pending_percent.round(1)
    end # method pending?

    # @return [Float] If the covered percentage is less than or equal to this
    #   value, the result is pending.
    def pending_percent
      95.0
    end # method failing_percent

    # @return [String] The string representation of the results.
    def to_s
      str = "#{covered_percent.round(2)}% coverage"

      str << ", #{missed_lines} missed lines"

      str << ", #{total_lines} total lines"
    end # method to_s
  end # class
end # module
