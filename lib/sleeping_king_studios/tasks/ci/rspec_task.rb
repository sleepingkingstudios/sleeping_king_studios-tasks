# lib/sleeping_king_studios/tasks/ci/rspec_task.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/rspec_results'
require 'sleeping_king_studios/tasks/ci/rspec_runner'

module SleepingKingStudios::Tasks::Ci
  # Defines a Thor task for running the full RSpec test suite.
  class RSpecTask < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the RSpec test suite.'
    end # class method description

    def self.task_name
      'rspec'
    end # class method task_name

    option :coverage,
      :type    => :boolean,
      :desc    => 'Enable or disable coverage with SimpleCov, if available.'
    option :format,
      :type    => :string,
      :desc    => 'The RSpec formatter to use. Defaults to the configuration.'
    option :gemfile,
      :type    => :string,
      :desc    => 'The Gemfile used to run the specs.',
      :default => ENV['BUNDLE_GEMFILE']
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

    def call *files
      results = rspec_runner(files.empty?).call(:files => files)

      raw? ? results : RSpecResults.new(results)
    end # method call

    private

    def default_format
      SleepingKingStudios::Tasks.configuration.ci.rspec.
        fetch(:format, :documentation)
    end # method default_format

    def default_gemfile
      File.join(Dir.pwd, 'Gemfile')
    end # method default_gemfile

    def gemfile
      return options['gemfile'] if options.key?('gemfile')

      gemfile = ENV['BUNDLE_GEMFILE']

      return gemfile if gemfile && gemfile != default_gemfile

      nil
    end # method gemfile

    def rspec_runner default_coverage = true
      coverage = options.fetch('coverage', default_coverage)

      env = options.fetch('__env__', {})
      env[:bundle_gemfile] = gemfile if gemfile
      env[:coverage]       = false unless coverage

      format = options.fetch('format', default_format)

      opts = %w(--color --tty)
      opts << "--format=#{format}" unless quiet?

      RSpecRunner.new(:env => env, :options => opts)
    end # method rspec_runner
  end # class
end # module
