# lib/sleeping_king_studios/tasks/apps/ci/simplecov.rb

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/ci/simplecov_results'
require 'sleeping_king_studios/tasks/task'

module SleepingKingStudios::Tasks::Apps::Ci
  # Defines a Thor task for aggregating SimpleCov coverage results across
  # applications.
  class SimpleCov < SleepingKingStudios::Tasks::Task
    RESULTS_STRUCT =
      Struct.new(
        :covered_lines,
        :covered_percent,
        :missed_lines,
        :total_lines
      ) # end struct

    def self.configure_simplecov!
      require 'simplecov'
      require 'simplecov-json'

      ::SimpleCov.configure do
        command_name "#{command_name}:#{ENV['APP_NAME']}" if ENV['APP_NAME']

        self.formatter =
          ::SimpleCov::Formatter::MultiFormatter.new(
            [formatter, ::SimpleCov::Formatter::JSONFormatter]
          ) # end formatter
      end # configure
    end # class method configure_simplecov!

    def self.description
      'Aggregates the SimpleCov results for all applications.'
    end # class method description

    def self.task_name
      'simplecov'
    end # class method task_name

    def call _application = nil
      results = load_report :report => File.join('coverage', 'coverage.json')
      results = convert_results_to_object(results)

      SleepingKingStudios::Tasks::Ci::SimpleCovResults.new(results)
    end # method call

    private

    def load_report report:
      raw  = File.read report
      json = JSON.parse raw

      json['metrics']
    rescue
      {}
    end # method load_report

    def convert_results_to_object hsh
      RESULTS_STRUCT.new(
        hsh.fetch('covered_lines', 0),
        hsh.fetch('covered_percent', 0.0),
        hsh.fetch('total_lines', 0) - hsh.fetch('covered_lines', 0),
        hsh.fetch('total_lines', 0)
      ) # end object
    end # method convert_results_to_object
  end # module
end # module
