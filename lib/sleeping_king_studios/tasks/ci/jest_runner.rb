# frozen_string_literal: true

require 'json'

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/process_runner'

module SleepingKingStudios::Tasks::Ci
  # Service object to run Jest as an external process with the specified
  # parameters.
  class JestRunner < SleepingKingStudios::Tasks::ProcessRunner
    def call env: {}, files: [], options: [], report: true
      report  = 'tmp/ci/jest.json' if report && !report.is_a?(String)
      command =
        build_command(
          :env     => env,
          :files   => files,
          :options => options,
          :report  => report
        )

      stream_process(command)

      report ? load_report(:report => report) : {}
    end

    private

    def base_command
      'yarn jest'
    end

    def build_options files:, options:, report:, **_kwargs
      options += ['--json', "--outputFile=#{report}"] if report

      super :files => files, :options => options
    end

    def load_report report:
      raw = File.read report

      return {} if raw.empty?

      JSON.parse raw
    rescue
      # :nocov:
      {}
      # :nocov:
    end
  end
end
