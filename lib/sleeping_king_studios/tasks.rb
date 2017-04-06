# lib/sleeping_king_studios/tasks.rb

require 'sleeping_king_studios/tools'

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # Toolkit providing an encapsulation layer around the Thor CLI library, with
  # predefined tasks for development and continuous integration.
  module Tasks
    autoload :Task,      'sleeping_king_studios/tasks/task'
    autoload :TaskGroup, 'sleeping_king_studios/tasks/task_group'
  end # module
end # module
