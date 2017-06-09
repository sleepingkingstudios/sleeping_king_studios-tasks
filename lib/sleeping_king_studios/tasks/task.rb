# lib/sleeping_king_studios/tasks/task.rb

require 'thor'

require 'sleeping_king_studios/tasks'

module SleepingKingStudios::Tasks
  # Encapsulates a Thor task as a class object.
  class Task
    include ::Thor::Shell

    module ClassMethods # rubocop:disable Style/Documentation
      # @return [String] The description of the task.
      def description
        'A non-descript task if ever there was one.'
      end # method description

      # Defines a permitted option for the task.
      #
      # @param option_name [String, Symbol] The name of the option.
      # @param option_params [Hash] Additional params for the option.
      #
      # @see https://github.com/erikhuda/thor/wiki/Method-Options
      def option option_name, option_params
        options[option_name] = option_params

        define_helpers option_name, option_params
      end # method option

      # @return [Hash] The permitted options for the task.
      def options
        @options ||= {}
      end # method options

      # @return [String] The name of the task.
      def task_name
        tools = SleepingKingStudios::Tools::Toolbelt.instance

        tools.string.underscore(name.split('::').last).sub(/_task$/, '')
      end # method task_name

      private

      def define_helpers option_name, option_params
        tools = SleepingKingStudios::Tools::Toolbelt.instance
        name  = tools.string.underscore option_name

        define_method(name) { options[option_name.to_s] }

        return unless option_params[:type] == :boolean

        default = option_params.fetch(:default, false)
        define_method(:"#{name}?") { options.fetch(option_name.to_s, default) }
      end # method define_helpers
    end # module
    extend ClassMethods

    # @param options [Hash] The command-line options passed in via Thor.
    def initialize options
      @options = options
    end # constructor

    # @return [Hash] The command-line options passed in via Thor.
    attr_reader :options

    # Performs the task with the given arguments. Overriden by subclasses.
    def call *_args; end

    # Mutes the task.
    def mute!
      @mute = true
    end # method mute!

    # @return [Boolean] True if the task has been muted, otherwise false.
    def mute?
      !!@mute
    end # method mute?
    alias_method :muted?, :mute?

    # Prints the given message unless the task has been muted.
    #
    # @see Thor::Shell#say.
    def say *args
      return if mute?

      super
    end # method say

    private

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
