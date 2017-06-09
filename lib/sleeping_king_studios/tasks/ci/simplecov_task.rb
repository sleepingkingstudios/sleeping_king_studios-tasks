# lib/sleeping_king_studios/tasks/ci/simplecov_task.rb

require 'simplecov'

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/simplecov_results'

module SleepingKingStudios::Tasks::Ci
  # Defines a Thor task for aggregating SimpleCov results.
  class SimpleCovTask < SleepingKingStudios::Tasks::Task
    def self.description
      'Aggregates the SimpleCov results.'
    end # class method description

    def self.task_name
      'simplecov'
    end # class method task_name

    def call *_args
      results = ::SimpleCov.result

      SimpleCovResults.new(results)
    end # method call
  end # class
end # module
