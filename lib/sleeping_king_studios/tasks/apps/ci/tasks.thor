# lib/sleeping_king_studios/tasks/apps/ci/tasks.thor

require 'sleeping_king_studios/tasks/apps/ci'
require 'sleeping_king_studios/tasks/apps/ci/rspec_task'
require 'sleeping_king_studios/tasks/apps/ci/rubocop_task'
require 'sleeping_king_studios/tasks/apps/ci/simplecov_task'
require 'sleeping_king_studios/tasks/apps/ci/steps_task'

module SleepingKingStudios::Tasks::Apps::Ci
  # Thor integration for continuous integration tasks in semi-distributed
  # applications.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :"apps:ci"

    task SleepingKingStudios::Tasks::Apps::Ci::RSpecTask
    task SleepingKingStudios::Tasks::Apps::Ci::RuboCopTask
    task SleepingKingStudios::Tasks::Apps::Ci::SimpleCovTask
    task SleepingKingStudios::Tasks::Apps::Ci::StepsTask
  end # class
end # module
