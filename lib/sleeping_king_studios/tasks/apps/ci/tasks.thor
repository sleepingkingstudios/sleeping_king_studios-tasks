# lib/sleeping_king_studios/tasks/apps/ci/tasks.thor

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/rspec'

module SleepingKingStudios::Tasks::Apps::Ci
  # Thor integration for continuous integration tasks in semi-distributed
  # applications.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :"apps:ci"

    task SleepingKingStudios::Tasks::Apps::Ci::RSpec
  end # class
end # module
