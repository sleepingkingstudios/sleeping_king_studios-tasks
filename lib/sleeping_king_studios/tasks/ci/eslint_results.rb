# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Encapsulates the results of an Eslint call.
  class EslintResults
    # @param results [Hash] The raw results of the Eslint call.
    def initialize results
      @results = results
    end

    # @param other [EslintResults] The other results object to compare.
    #
    # @return [Boolean] True if the results are equal, otherwise false.
    def == other
      if other.is_a?(Array)
        empty? ? other.empty? : @results == other
      elsif other.is_a?(EslintResults)
        to_h == other.to_h
      else
        false
      end
    end

    # @return [Boolean] True if there are no inspected files, otherwise false.
    def empty?
      inspected_file_count.zero?
    end

    # @return [Integer] The total number of error results across all files.
    def error_count
      @error_count ||= @results.map { |hsh| hsh['errorCount'] }.sum
    end

    # @return [Boolean] True if there are no errors or warnings, otherwise
    #   false.
    def failing?
      !(error_count.zero? && warning_count.zero?)
    end

    # @return [Integer] The number of inspected files.
    def inspected_file_count
      @results.size
    end

    # @return [Boolean] Always false. Both warnings and errors trigger a failure
    #   state.
    def pending?
      false
    end

    # @return [Hash] The hash representation of the results.
    def to_h
      {
        'inspected_file_count' => inspected_file_count,
        'error_count'          => error_count,
        'warning_count'        => warning_count
      }
    end

    # @return [String] The string representation of the results.
    def to_s # rubocop:disable Metrics/AbcSize
      str = +"#{pluralize inspected_file_count, 'file'} inspected"

      str << ", #{pluralize error_count, 'error'}"

      str << ", #{pluralize warning_count, 'warning'}"

      str << "\n" unless non_empty_results.empty?

      non_empty_results.each do |hsh|
        str << "\n    #{format_result_item(hsh)}"
      end

      str
    end

    # @return [Integer] The total number of warning results across all files.
    def warning_count
      @warning_count ||= @results.map { |hsh| hsh['warningCount'] }.sum
    end

    private

    def format_result_item hsh
      str = +relative_path(hsh['filePath'])

      str << ": #{pluralize hsh['errorCount'], 'error'}"

      str << ", #{pluralize hsh['warningCount'], 'warning'}"
    end

    def non_empty_results
      @results.reject do |hsh|
        hsh['errorCount'].zero? && hsh['warningCount'].zero?
      end
    end

    def pluralize count, singular, plural = nil
      "#{count} #{tools.int.pluralize count, singular, plural}"
    end

    def relative_path path
      path.sub(/\A#{Dir.getwd}#{File::SEPARATOR}?/, '')
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
