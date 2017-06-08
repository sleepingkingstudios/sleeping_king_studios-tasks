# lib/sleeping_king_studios/tasks/ci/cucumber_runner.rb

require 'json'

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/cucumber_parser'
require 'sleeping_king_studios/tasks/process_runner'

module SleepingKingStudios::Tasks::Ci
  # Service object to run Cucumber as an external process with the specified
  # parameters.
  class CucumberRunner < SleepingKingStudios::Tasks::ProcessRunner
    def call env: {}, files: [], options: [], report: true
      report  = 'tmp/ci/cucumber.json' if report && !report.is_a?(String)
      command =
        build_command(
          :env     => env,
          :files   => files,
          :options => options,
          :report  => report
        ) # end build_command

      stream_process(command)

      report ? load_report(:report => report) : {}
    end # method call

    private

    def base_command
      'bundle exec cucumber'
    end # method base_command

    def build_options files:, options:, report:, **_kwargs
      options += ['--format=json', "--out=#{report}"] if report

      super :files => files, :options => options
    end # method build_options

    def load_report report:
      raw = File.read report

      return {} if raw.empty?

      json   = JSON.parse raw
      parser = SleepingKingStudios::Tasks::Ci::CucumberParser

      parser.parse(json)
    rescue
      {}
    end # method load_report
  end # class
end # module
