# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci'
require 'sleeping_king_studios/tasks/ci/eslint_results'
require 'sleeping_king_studios/tasks/ci/eslint_runner'

module SleepingKingStudios::Tasks::Ci
  # Defines a Thor task for running the Eslint linter.
  class EslintTask < SleepingKingStudios::Tasks::Task
    def self.description
      'Runs the ESLint linter.'
    end

    def self.task_name
      'eslint'
    end

    def call *files
      results = eslint_runner.call(:files => files)

      EslintResults.new(results)
    end

    private

    def eslint_runner
      opts = %w(--color)

      EslintRunner.new(:options => opts)
    end
  end
end
