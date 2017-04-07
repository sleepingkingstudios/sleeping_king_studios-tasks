# lib/sleeping_king_studios/tasks/ci/rubocop_runner.rb

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/process_runner'

module SleepingKingStudios::Tasks::Ci
  # Service object to run RuboCop as an external process with the specified
  # parameters.
  class RuboCopRunner < SleepingKingStudios::Tasks::ProcessRunner
    def call env: {}, files: [], options: [], report: true
      report  = 'tmp/ci/rubocop.json' if report && !report.is_a?(String)
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
      'bundle exec rubocop'
    end # method base_command

    def build_options files:, options:, report:, **_kwargs
      options += ['--format=json', "--out=#{report}"] if report

      super :files => files, :options => options
    end # method build_options

    def load_report report:
      raw  = File.read report
      json = JSON.parse raw

      json['summary']
    rescue
      {}
    end # method load_report
  end # class
end # module
