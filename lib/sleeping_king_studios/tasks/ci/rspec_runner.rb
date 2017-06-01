# lib/sleeping_king_studios/tasks/ci/rspec_runner.rb

require 'json'

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/process_runner'

module SleepingKingStudios::Tasks::Ci
  # Service object to run RSpec as an external process with the specified
  # parameters.
  class RSpecRunner < SleepingKingStudios::Tasks::ProcessRunner
    def call env: {}, files: [], options: [], report: true
      report  = 'tmp/ci/rspec.json' if report && !report.is_a?(String)
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
      'bundle exec rspec'
    end # method base_command

    def build_options files:, options:, report:, **_kwargs
      options += ['--format=json', "--out=#{report}"] if report

      super :files => files, :options => options
    end # method build_options

    def load_report report:
      raw = File.read report

      return {} if raw.empty?

      json = JSON.parse raw
      hsh  = json['summary']

      hsh['error_count'] = parse_errors(json['summary_line'])

      hsh
    rescue
      {}
    end # method load_report

    def parse_errors summary
      return 0 unless summary && !summary.empty?

      match = summary.match(/(?<digits>\d+) error/)

      match ? match[:digits].to_i : 0
    end # method parse_errors
  end # class
end # module
