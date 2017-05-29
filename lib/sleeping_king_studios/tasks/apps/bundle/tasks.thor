# lib/sleeping_king_studios/tasks/apps/bundle/tasks.thor

require 'sleeping_king_studios/tasks/apps/bundle'
require 'sleeping_king_studios/tasks/apps/bundle/install'
require 'sleeping_king_studios/tasks/apps/bundle/update'

module SleepingKingStudios::Tasks::Apps::Bundle
  # Thor integration for application gem dependency tasks.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :"apps:bundle"

    task SleepingKingStudios::Tasks::Apps::Bundle::Install
    task SleepingKingStudios::Tasks::Apps::Bundle::Update
  end # class
end # module
