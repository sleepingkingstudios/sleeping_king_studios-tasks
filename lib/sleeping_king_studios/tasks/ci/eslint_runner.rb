# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/process_runner'

module SleepingKingStudios::Tasks::Ci
  # Service object to run Eslint as an external process with the specified
  # parameters.
  class EslintRunner < SleepingKingStudios::Tasks::ProcessRunner
    def call env: {}, files: [], options: [], report: true
      report  = 'tmp/ci/eslint.json' if report && !report.is_a?(String)
      command =
        build_command(
          :env     => env,
          :files   => files,
          :options => options,
          :report  => report
        )

      stream_process(command)

      report ? load_report(:report => report) : []
    end

    private

    def base_command
      'yarn eslint'
    end

    def build_options files:, options:, report:, **_kwargs
      files = default_files if files.empty?
      options += ['--format=json', "--output-file=#{report}"] if report

      super :files => files, :options => options
    end

    def default_files
      SleepingKingStudios::Tasks.configuration.ci.eslint.
        fetch(:default_files, '"**/*.js"')
    end

    def load_report report:
      raw = File.read report

      JSON.parse raw
    rescue
      []
    end
  end
end
