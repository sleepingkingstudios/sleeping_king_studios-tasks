# lib/sleeping_king_studios/tasks/ci/tasks.thor

require 'sleeping_king_studios/tasks/ci/rubocop'
require 'sleeping_king_studios/tasks/ci/rspec'
require 'sleeping_king_studios/tasks/ci/rspec_each'
require 'sleeping_king_studios/tasks/ci/steps'

module SleepingKingStudios::Tasks::Ci
  # Thor integration for continuous integration tasks.
  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    namespace :ci

    task SleepingKingStudios::Tasks::Ci::RuboCop
    task SleepingKingStudios::Tasks::Ci::RSpec
    task SleepingKingStudios::Tasks::Ci::RSpecEach
    task SleepingKingStudios::Tasks::Ci::Steps
  end # class
end # module
