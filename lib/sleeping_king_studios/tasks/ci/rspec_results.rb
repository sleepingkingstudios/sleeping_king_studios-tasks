# lib/sleeping_king_studios/tasks/ci/rspec_results.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Encapsulates the results of an RSpec call.
  class RSpecResults
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
      elsif other.is_a?(RSpecResults)
        to_h == other.to_h
      else
        false
      end # if-elsif-else
    end # method ==

    # @return [Float] The duration value.
    def duration
      @results.fetch('duration', 0.0)
    end # method duration

    # @return [Boolean] True if there are no examples, otherwise false.
    def empty?
      example_count.zero?
    end # method empty?

    # @return [Boolean] True if there are no results, otherwise false.
    def errored?
      @results.empty?
    end # method errored?

    # @return [Integer] The total number of examples.
    def example_count
      @results.fetch('example_count', 0)
    end # method example_count

    # @return [Boolean] True if there are any failing examples, otherwise false.
    def failing?
      !failure_count.zero?
    end # method failing?

    # @return [Integer] The number of failing examples.
    def failure_count
      @results.fetch('failure_count', 0)
    end # method failure_count

    # @return [Boolean] True if there are any pending examples, otherwise false.
    def pending?
      !pending_count.zero?
    end # method pending?

    # @return [Intger] The number of pending examples.
    def pending_count
      @results.fetch('pending_count', 0)
    end # method pending_count

    # @return [Hash] The hash representation of the results.
    def to_h
      {
        'duration'      => duration,
        'example_count' => example_count,
        'failure_count' => failure_count,
        'pending_count' => pending_count
      } # end hash
    end # method to_h

    # @return [String] The string representation of the results.
    def to_s
      str = "#{example_count} examples"

      str << ", #{failure_count} failures"

      str << ", #{pending_count} pending" if pending?

      str << " in #{duration.round(2)} seconds"
    end # method to_s
  end # class
end # module
