# lib/sleeping_king_studios/tasks/apps/ci/tasks.thor

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/rspec'
require 'sleeping_king_studios/tasks/apps/ci/rubocop'
require 'sleeping_king_studios/tasks/apps/ci/simplecov'
require 'sleeping_king_studios/tasks/apps/ci/steps'

module SleepingKingStudios::Tasks::Apps::Ci
  # Thor integration for continuous integration tasks in semi-distributed
  # applications.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :"apps:ci"

    task SleepingKingStudios::Tasks::Apps::Ci::RSpec
    task SleepingKingStudios::Tasks::Apps::Ci::RuboCop
    task SleepingKingStudios::Tasks::Apps::Ci::Steps
    task SleepingKingStudios::Tasks::Apps::Ci::SimpleCov
  end # class
end # module
