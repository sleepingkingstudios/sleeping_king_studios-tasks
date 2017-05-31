# lib/sleeping_king_studios/tasks/ci/rspec_each_results.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Encapsulates the results of an RSpecEach call.
  class RSpecEachResults
    # @param results [Hash] The raw results of the RSpecEach call.
    def initialize results
      @results = results
    end # constructor

    # @param other [RSpecEachResults] The other results object to compare.
    #
    # @return [Boolean] True if the results are equal, otherwise false.
    def == other
      if other.is_a?(Hash)
        empty? ? other.empty? : to_h == other
      elsif other.is_a?(RSpecEachResults)
        to_h == other.to_h
      else
        false
      end # if-elsif-else
    end # method ==

    # @return [Float] The duration value.
    def duration
      @results.fetch('duration', 0.0)
    end # method duration

    # @return [Boolean] True if there are no files, otherwise false.
    def empty?
      file_count.zero?
    end # method empty?

    # @return [Boolean] True if there are any errored files, otherwise false.
    def errored?
      !errored_count.zero?
    end # method errored?

    # @return [Integer] The number of errored files.
    def errored_count
      errored_files.count
    end # method errored_count

    # @return [Array] The list of errored file names.
    def errored_files
      @results.fetch('errored_files', [])
    end # method errored_files

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

    def pluralize count, singular, plural = nil
      "#{count} #{tools.integer.pluralize count, singular, plural}"
    end # method pluralize

    # @return [Hash] The hash representation of the results.
    def to_h
      {
        'failing_files' => failing_files,
        'pending_files' => pending_files,
        'errored_files' => errored_files,
        'file_count'    => file_count,
        'duration'      => duration
      } # end hash
    end # method to_h

    # @return [String] The string representation of the results.
    def to_s
      str = "#{file_count} files"

      str << ', ' << pluralize(failure_count, 'failure')

      str << ", #{pending_count} pending" if pending?

      str << ", #{errored_count} errored" if errored?

      str << " in #{duration.round(2)} seconds"
    end # method to_s

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
