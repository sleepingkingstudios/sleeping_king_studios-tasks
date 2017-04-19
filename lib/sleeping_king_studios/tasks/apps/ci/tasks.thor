# lib/sleeping_king_studios/tasks/apps/ci/tasks.thor

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/rspec'
require 'sleeping_king_studios/tasks/apps/ci/rubocop'

module SleepingKingStudios::Tasks::Apps::Ci
  # Thor integration for continuous integration tasks in semi-distributed
  # applications.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :"apps:ci"

    task SleepingKingStudios::Tasks::Apps::Ci::RSpec
    task SleepingKingStudios::Tasks::Apps::Ci::RuboCop
  end # class
end # module
