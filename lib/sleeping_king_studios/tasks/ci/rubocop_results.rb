# lib/sleeping_king_studios/tasks/ci/rubocop_results.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Encapsulates the results of a RuboCop call.
  class RuboCopResults
    # @param results [Hash] The raw results of the RuboCop call.
    def initialize results
      @results = results
    end # constructor

    # @param other [RSpecResults] The other results object to compare.
    #
    # @return [Boolean] True if the results are equal, otherwise false.
    def == other
      if other.is_a?(Hash)
        empty? ? other.empty? : to_h == other
      elsif other.is_a?(RuboCopResults)
        to_h == other.to_h
      else
        false
      end # if-elsif-else
    end # method ==

    # @return [Boolean] True if there are no inspected files, otherwise false.
    def empty?
      inspected_file_count.zero?
    end # method empty?

    # @return [Boolean] True if there are any offenses, otherwise false.
    def failing?
      !offense_count.zero?
    end # method failing?

    # @return [Integer] The number of inspected files.
    def inspected_file_count
      @results.fetch('inspected_file_count', 0)
    end # method inspected_file_count

    # Adds the given result values and returns a new results object with the
    # sums.
    #
    # @param other [RuboCopResults] The results to add.
    #
    # @return [RuboCopResults] The total results.
    def merge other
      self.class.new(
        'inspected_file_count' =>
          inspected_file_count + other.inspected_file_count,
        'offense_count'        => offense_count + other.offense_count
      ) # end new
    end # method merge

    # @return [Integer] The number of detected offenses.
    def offense_count
      @results.fetch('offense_count', 0)
    end # method offense_count

    # @return [Boolean] False.
    def pending?
      false
    end # method pending?

    # @return [Hash] The hash representation of the results.
    def to_h
      {
        'inspected_file_count' => inspected_file_count,
        'offense_count'        => offense_count
      } # end hash
    end # method to_h

    # @return [String] The string representation of the results.
    def to_s
      str = "#{inspected_file_count} files inspected"

      str << ", #{offense_count} offenses"
    end # method to_s
  end # class
end # module
