# lib/sleeping_king_studios/tasks/ci/tasks.thor

require 'sleeping_king_studios/tasks/ci/rspec'

module SleepingKingStudios::Tasks::Ci
  # Thor integration for continuous integration tasks.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :ci

    task SleepingKingStudios::Tasks::Ci::RSpec
  end # class
end # module
