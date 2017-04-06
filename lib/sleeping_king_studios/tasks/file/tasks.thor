# lib/sleeping_king_studios/tasks/file/tasks.thor

require 'sleeping_king_studios/tasks/file'
require 'sleeping_king_studios/tasks/file/new'

module SleepingKingStudios::Tasks::File
  # Thor integration for file tasks.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :file

    task SleepingKingStudios::Tasks::File::New
  end # class
end # module
