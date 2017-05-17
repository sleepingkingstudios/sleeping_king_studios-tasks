# lib/sleeping_king_studios/tasks/process_runner.rb

require 'sleeping_king_studios/tasks'

module SleepingKingStudios::Tasks
  # Base class for helpers that execute a system process.
  class ProcessRunner
    # @param env [Hash] Environment variables to set for the RSpec process.
    # @param options [Array] Options to pass to RSpec.
    def initialize env: {}, options: []
      @default_env     = env
      @default_options = options

      return unless ENV['BUNDLE_GEMFILE']

      @default_env = @default_env.merge :bundle_gemfile => ENV['BUNDLE_GEMFILE']
    end # constructor

    # @return [Hash] Environment variables to set for the RSpec process.
    attr_reader :default_env

    # @return [Array] Options to pass to RSpec.
    attr_reader :default_options

    private

    def base_command
      ':'
    end # method base_command

    def build_command **kwargs
      env  = build_environment(kwargs)
      opts = build_options(kwargs)

      "#{env} #{base_command} #{opts}".strip
    end # method build_command

    def build_environment env:, **_kwargs
      default_env.
        merge(env).
        map do |key, value|
          key   = tools.string.underscore(key).upcase
          value = %("#{value}") if value.is_a?(String)

          "#{key}=#{value}"
        end. # map
        join ' '
    end # method build_environment

    def build_options files: [], options: [], **_kwargs
      (Array(files) + default_options + options).join ' '
    end # method build_options

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
