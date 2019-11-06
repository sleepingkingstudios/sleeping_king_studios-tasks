# lib/sleeping_king_studios/tasks/ci/rspec_each_task.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/results_helpers'
require 'sleeping_king_studios/tasks/ci/rspec_each_results'
require 'sleeping_king_studios/tasks/ci/rspec_results'
require 'sleeping_king_studios/tasks/ci/rspec_runner'

module SleepingKingStudios::Tasks::Ci
  # rubocop:disable Metrics/ClassLength

  # Defines a Thor task for running the full RSpec test suite.
  class RSpecEachTask < SleepingKingStudios::Tasks::Task
    include SleepingKingStudios::Tasks::Ci::ResultsHelpers

    def self.description
      'Runs each spec file as an individual RSpec process.'
    end # class method description

    def self.task_name
      'rspec_each'
    end # class method task_name

    option :format,
      :type    => :string,
      :desc    => 'The RSpec formatter to use. Defaults to the configuration.'
    option :quiet,
      :aliases => '-q',
      :type    => :boolean,
      :default => false,
      :desc    => 'Do not write spec results to STDOUT.'
    option :raw,
      :aliases => '-r',
      :type    => :boolean,
      :default => false,
      :desc    => 'Return a Hash instead of a results object.'

    def call *groups
      mute! if quiet?

      files = files_list(groups)

      say "Running #{files.count} spec files..."
      say "\n"

      results = run_files(files)

      report_pending results
      report_failing results
      report_errored results
      report_totals  results

      raw? ? results.to_h : results
    end # method call

    private

    def aggregate_results file, results, totals
      if results.errored?
        totals['errored_files'] << file
      elsif results.failing?
        totals['failing_files'] << file
      elsif results.pending?
        totals['pending_files'] << file
      end # if-else

      totals['file_count'] += 1
    end # method aggregate_results

    def build_totals
      {
        'pending_files' => [],
        'failing_files' => [],
        'errored_files' => [],
        'file_count'    => 0
      } # end results
    end # method build_totals

    def default_format
      SleepingKingStudios::Tasks.configuration.ci.rspec_each.
        fetch(:format, :documentation)
    end # method default_format

    def files_list groups
      groups = %w[spec] if groups.empty?

      groups.map do |group_or_file|
        if File.extname(group_or_file).empty?
          Dir[File.join group_or_file, pattern]
        else
          [group_or_file]
        end # if-else
      end. # map
        flatten.
        uniq
    end # method files_list

    def pattern
      '**{,/*/**}/*_spec.rb'
    end # method pattern

    def report_errored results
      return unless results.errored?

      say "\nErrored:\n\n"

      results.errored_files.each { |file| say "  #{file}", :red }
    end # report_pending

    def report_failing results
      return unless results.failing?

      say "\nFailures:\n\n"

      results.failing_files.each { |file| say "  #{file}", :red }
    end # report_pending

    def report_pending results
      return unless results.pending?

      say "\nPending:\n\n"

      results.pending_files.each { |file| say "  #{file}", :yellow }
    end # report_pending

    def report_totals results
      say "\nFinished in #{results.duration.round(2)} seconds"

      if results.failing? || results.errored?
        say results.to_s, :red
      elsif results.pending? || results.empty?
        say results.to_s, :yellow
      else
        say results.to_s, :green
      end # if-elsif-else
    end # method report_totals

    def rspec_runner
      RSpecRunner.new(:env => { :coverage => false })
    end # method rspec_runner

    def run_file file
      opts   = []
      format = options.fetch('format', default_format)

      if format && !quiet?
        opts = %w[--color --tty]
        opts << "--format=#{format}"
      end # if

      results = rspec_runner.call(:files => [file], :options => opts)
      results = RSpecResults.new(results)

      say "#{set_color results_state(results), results_color(results)} #{file}"

      results
    end # method run_file

    def run_files files
      start  = Time.now
      totals = build_totals

      files.each { |file| aggregate_results(file, run_file(file), totals) }

      totals['duration'] = Time.now - start

      RSpecEachResults.new(totals)
    end # method run_files
  end # class

  # rubocop:enable Metrics/ClassLength
end # module
