# lib/sleeping_king_studios/tasks/ci/rspec_each_results.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Encapsulates the results of an RSpecEach call.
  class RSpecEachResults
    # @param results [Hash] The raw results of the RSpecEach call.
    def initialize results
      @results = results
    end # constructor

    # @return [Float] The duration value.
    def duration
      @results.fetch('duration', 0.0)
    end # method duration

    # @return [Boolean] True if there are no files, otherwise false.
    def empty?
      file_count.zero?
    end # method empty?

    # @return [Boolean] True if there are any failing files, otherwise false.
    def failing?
      !failure_count.zero?
    end # method failing?

    # @return [Array] The list of failing file names.
    def failing_files
      @results.fetch('failing_files', [])
    end # method failing_files

    # @return [Integer] The number of failing files.
    def failure_count
      failing_files.count
    end # method failing_files

    # @return [Integer] The total file count.
    def file_count
      @results.fetch('file_count', 0)
    end # method file_count

    # @return [Boolean] True if there are any pending files, otherwise false.
    def pending?
      !pending_count.zero?
    end # method pending?

    # @return [Integer] The number of pending files.
    def pending_count
      pending_files.count
    end # method pending_count

    # @return [Array] The list of pending file names.
    def pending_files
      @results.fetch('pending_files', [])
    end # method pending_files

    # @return [Hash] The hash representation of the results.
    def to_h
      {
        'failing_files' => failing_files,
        'pending_files' => pending_files,
        'file_count'    => file_count,
        'duration'      => duration
      } # end hash
    end # method to_h

    # @return [String] The string representation of the results.
    def to_s
      str = "#{file_count} files"

      str << ", #{failure_count} failures"

      str << ", #{pending_count} pending" if pending?

      str << " in #{duration.round(2)} seconds"
    end # method to_s
  end # class
end # module
