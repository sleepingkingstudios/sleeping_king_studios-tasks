# lib/sleeping_king_studios/tasks/task.rb

require 'sleeping_king_studios/tasks'

module SleepingKingStudios::Tasks
  # Encapsulates a Thor task as a class object.
  class Task
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
      end # method option

      # @return [Hash] The permitted options for the task.
      def options
        @options ||= {}
      end # method options

      # @return [String] The name of the task.
      def task_name
        tools = SleepingKingStudios::Tools::Toolbelt.instance

        tools.string.underscore(name.split('::').last)
      end # method task_name
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
  end # class
end # module
