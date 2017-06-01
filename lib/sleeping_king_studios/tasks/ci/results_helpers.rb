# lib/sleeping_king_studios/tasks/ci/results_helpers.rb

require 'sleeping_king_studios/tasks/ci'

module SleepingKingStudios::Tasks::Ci
  # Helper methods for reporting CI results.
  module ResultsHelpers
    private

    # Returns a terminal color corresponding to the state of the results object.
    #
    # @param results [Object] The results object.
    #
    # @return [Symbol] The terminal color.
    def results_color results
      if results.failing?
        :red
      elsif results.respond_to?(:errored?) && results.errored?
        :red
      elsif results.pending? || results.empty?
        :yellow
      else
        :green
      end # if-elsif-else
    end # method set_results_color

    # Returns a state string for the results object.
    #
    # @param results [Object] The results object.
    #
    # @return [String] The results state.
    def results_state results
      if results.respond_to?(:errored?) && results.errored?
        'Errored'
      elsif results.failing?
        'Failing'
      elsif results.pending? || results.empty?
        'Pending'
      else
        'Passing'
      end # if-elsif-else
    end # method results_state
  end # module
end # module
