# lib/sleeping_king_studios/tasks/apps/bundle/tasks.thor

require 'sleeping_king_studios/tasks/apps/bundle'
require 'sleeping_king_studios/tasks/apps/bundle/install_task'
require 'sleeping_king_studios/tasks/apps/bundle/update_task'

module SleepingKingStudios::Tasks::Apps::Bundle
  # Thor integration for application gem dependency tasks.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :"apps:bundle"

    task SleepingKingStudios::Tasks::Apps::Bundle::InstallTask
    task SleepingKingStudios::Tasks::Apps::Bundle::UpdateTask
  end # class
end # module
