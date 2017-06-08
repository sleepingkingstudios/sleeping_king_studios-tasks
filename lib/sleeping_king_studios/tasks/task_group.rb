# lib/sleeping_king_studios/tasks/task_group.rb

require 'thor'

require 'sleeping_king_studios/tasks'

module SleepingKingStudios::Tasks
  # Exposes a group of encapsulated tasks with a shared namespace to Thor.
  class TaskGroup < ::Thor
    module ClassMethods # rubocop:disable Style/Documentation
      # Adds a task definition to the task group. The task name, description,
      # and method options (if any) are resolved from the task class, and a
      # wrapper method is defined for calling the task.
      def task definition, options = {}
        task_name = options.fetch(:as, definition.task_name)

        desc(task_name, definition.description)

        definition.options.each do |option_name, option_params|
          method_option option_name, option_params
        end # each

        define_method(task_name) do |*args|
          definition.new(self.options).call(*args)
        end # define_method
      end # class method task

      # @return [Boolean] True.
      def exit_on_failure?
        # :nocov:
        true
        # :nocov:
      end # class method exit_on_failure?
    end # module
    extend ClassMethods
  end # class
end # module
