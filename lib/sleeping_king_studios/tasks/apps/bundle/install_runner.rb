# lib/sleeping_king_studios/tasks/apps/bundle/install_runner.rb

require 'sleeping_king_studios/tasks/apps/bundle'
require 'sleeping_king_studios/tasks/process_runner'

module SleepingKingStudios::Tasks::Apps::Bundle
  # Service object to run bundle install as an external process.
  class InstallRunner < SleepingKingStudios::Tasks::ProcessRunner
    def call gemfile
      command = build_command :env => { :bundle_gemfile => gemfile }

      stream_process(command)
    end # method call

    private

    def base_command
      'bundle install'
    end # method base_command
  end # module
end # module
