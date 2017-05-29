# lib/sleeping_king_studios/tasks/apps/bundle/update_runner.rb

require 'sleeping_king_studios/tasks/apps/bundle'
require 'sleeping_king_studios/tasks/process_runner'

module SleepingKingStudios::Tasks::Apps::Bundle
  # Service object to run bundle update as an external process.
  class UpdateRunner < SleepingKingStudios::Tasks::ProcessRunner
    def call gemfile
      command = build_command :env => { :bundle_gemfile => gemfile }

      stream_process(command)
    end # method call

    private

    def base_command
      'bundle update'
    end # method base_command
  end # class
end # module
