# lib/sleeping_king_studios/tasks/ci/rspec_runner.rb

require 'json'

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Service object to run RSpec as an external process with the specified
  # parameters.
  class RSpecRunner
    # @param env [Hash] Environment variables to set for the RSpec process.
    # @param options [Array] Options to pass to RSpec.
    def initialize env: {}, options: []
      @default_env     = env
      @default_options = options
    end # constructor

    # @return [Hash] Environment variables to set for the RSpec process.
    attr_reader :default_env

    # @return [Array] Options to pass to RSpec.
    attr_reader :default_options

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

    def build_command env:, files:, options:, report:
      env     = default_env.merge env
      env     = env.map { |k, v| "#{tools.string.underscore(k).upcase}=#{v}" }
      options =
        build_options :files => files, :options => options, :report => report

      "#{env.join ' '} bundle exec rspec #{options.join ' '}".strip
    end # method build_command

    def build_options files:, options:, report:
      options = Array(files) + default_options + options
      options << '--format=json' << "--out=#{report}" if report

      options
    end # method build_options

    def load_report report:
      raw  = File.read report
      json = JSON.parse raw

      json['summary']
    rescue
      {}
    end # method load_report

    def stream_process command
      Bundler.with_clean_env do
        IO.popen(command) do |io|
          loop do
            char = io.getc

            char ? print(char) : break
          end # loop
        end # popen
      end # with_clean_env
    end # method stream_process

    def tools
      SleepingKingStudios::Tools::Toolbelt.new
    end # method tools
  end # class
end # module
