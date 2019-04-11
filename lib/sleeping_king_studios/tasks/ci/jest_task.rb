# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/jest_results'
require 'sleeping_king_studios/tasks/ci/jest_runner'

module SleepingKingStudios::Tasks::Ci
  # Defines a Thor task for running the full Jest (JavaScript) test suite.
  class JestTask < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the Jest test suite.'
    end

    def self.task_name
      'jest'
    end

    def call *files
      results = jest_runner.call(:files => files)

      JestResults.new(results)
    end

    private

    def jest_runner
      env  = options.fetch('__env__', {})
      opts = %w(--color)

      JestRunner.new(:env => env, :options => opts)
    end
  end
end
