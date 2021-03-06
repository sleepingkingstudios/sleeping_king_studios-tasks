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

    # @return [Boolean] True if there are no results or if errors occurred
    #   outside of examples, otherwise false.
    def errored?
      @results.empty? || !error_count.zero?
    end # method errored?

    # @return [Integer] The number of errors that occurred outside of examples.
    def error_count
      @results.fetch('error_count', 0)
    end # method error_count

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

    # Adds the given result values and returns a new results object with the
    # sums.
    #
    # @param other [RSpecResults] The results to add.
    #
    # @return [RSpecResults] The total results.
    def merge other
      self.class.new(
        'duration'      => duration      + other.duration,
        'example_count' => example_count + other.example_count,
        'failure_count' => failure_count + other.failure_count,
        'pending_count' => pending_count + other.pending_count
      ) # end new
    end # method merge

    # @return [Boolean] True if there are any pending examples, otherwise false.
    def pending?
      !pending_count.zero?
    end # method pending?

    # @return [Intger] The number of pending examples.
    def pending_count
      @results.fetch('pending_count', 0)
    end # method pending_count

    def pluralize count, singular, plural = nil
      "#{count} #{tools.int.pluralize count, singular, plural}"
    end # method pluralize

    # @return [Hash] The hash representation of the results.
    def to_h
      {
        'duration'      => duration,
        'example_count' => example_count,
        'failure_count' => failure_count,
        'pending_count' => pending_count,
        'error_count'   => error_count
      } # end hash
    end # method to_h

    # rubocop:disable Metrics/AbcSize

    # @return [String] The string representation of the results.
    def to_s
      str = pluralize(example_count, 'example')

      str << ', ' << pluralize(failure_count, 'failure')

      str << ', ' << pending_count.to_s << ' pending' if pending?

      if error_count.zero?
        str << " in #{duration.round(2)} seconds"
      else
        str << ', ' << pluralize(error_count, 'error') <<
          ' occurred outside of examples'
      end # if-else
    end # method to_s

    # rubocop:enable Metrics/AbcSize

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
