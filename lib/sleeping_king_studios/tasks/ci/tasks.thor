# lib/sleeping_king_studios/tasks/ci/tasks.thor

require 'sleeping_king_studios/tasks/ci/cucumber_task'
require 'sleeping_king_studios/tasks/ci/rspec_task'
require 'sleeping_king_studios/tasks/ci/rspec_each_task'
require 'sleeping_king_studios/tasks/ci/rubocop_task'
require 'sleeping_king_studios/tasks/ci/steps_task'

module SleepingKingStudios::Tasks::Ci
  # Thor integration for continuous integration tasks.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :ci

    task SleepingKingStudios::Tasks::Ci::CucumberTask
    task SleepingKingStudios::Tasks::Ci::RSpecTask
    task SleepingKingStudios::Tasks::Ci::RSpecEachTask
    task SleepingKingStudios::Tasks::Ci::RuboCopTask
    task SleepingKingStudios::Tasks::Ci::StepsTask
  end # class
end # module
