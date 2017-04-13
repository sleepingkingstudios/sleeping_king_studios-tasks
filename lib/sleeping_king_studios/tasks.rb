# lib/sleeping_king_studios/tasks.rb

require 'sleeping_king_studios/tools'

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # Toolkit providing an encapsulation layer around the Thor CLI library, with
  # predefined tasks for development and continuous integration.
  module Tasks
    autoload :Configuration, 'sleeping_king_studios/tasks/configuration'
    autoload :Task,          'sleeping_king_studios/tasks/task'
    autoload :TaskGroup,     'sleeping_king_studios/tasks/task_group'

    def self.configuration
      @configuration ||= SleepingKingStudios::Tasks::Configuration.new
    end # class method configuration

    # The file path to the root of the gem directory.
    def self.gem_path
      @gem_path ||= __dir__.sub %r{/lib/sleeping_king_studios\z}, ''
    end # class method gem_path
  end # module
end # module
