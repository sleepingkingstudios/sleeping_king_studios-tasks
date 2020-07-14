# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Encapsulates the results of a Jest call.
  class JestResults
    # @param results [Hash] The raw results of the Jest call.
    def initialize results
      @results = results
    end

    # @param other [JestResults] The other results object to compare.
    #
    # @return [Boolean] True if the results are equal, otherwise false.
    def == other
      if other.is_a?(Hash)
        empty? ? other.empty? : @results == other
      elsif other.is_a?(JestResults)
        to_h == other.to_h
      else
        false
      end
    end

    # @return [Float] The duration value, in seconds.
    def duration
      (end_time - start_time).to_f / 1000
    end

    # @return [Boolean] True if there are no tests, otherwise false.
    def empty?
      test_count.zero?
    end

    # @return [Boolean] True if there are any failing tests, otherwise false.
    def failing?
      !failure_count.zero?
    end

    # @return [Integer] The number of failing tests.
    def failure_count
      @results.fetch('numFailedTests', 0)
    end

    # @return [Boolean] True if there are any pending tests, otherwise false.
    def pending?
      !pending_count.zero?
    end

    # @return [Intger] The number of pending tests.
    def pending_count
      @results.fetch('numPendingTests', 0)
    end

    # @return [Integer] The total number of tests.
    def test_count
      @results.fetch('numTotalTests', 0)
    end

    # @return [Hash] The hash representation of the results.
    def to_h
      {
        'duration'      => duration,
        'failure_count' => failure_count,
        'pending_count' => pending_count,
        'test_count'    => test_count
      }
    end

    # @return [String] The string representation of the results.
    def to_s # rubocop:disable Metrics/AbcSize
      str = +pluralize(test_count, 'test')

      str << ', ' << pluralize(failure_count, 'failure')

      str << ', ' << pending_count.to_s << ' pending' if pending?

      str << " in #{duration.round(2)} seconds"
    end

    private

    def end_time
      return 0 unless @results['testResults']

      @results['testResults'].
        map { |test_result| test_result['endTime'] }.
        reduce do |memo, time|
          [memo, time].max
        end
    end

    def pluralize count, singular, plural = nil
      "#{count} #{tools.int.pluralize count, singular, plural}"
    end

    def start_time
      @results['startTime'] || 0
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
