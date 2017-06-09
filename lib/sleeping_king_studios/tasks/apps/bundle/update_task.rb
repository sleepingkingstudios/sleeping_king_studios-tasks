# lib/sleeping_king_studios/tasks/apps/bundle/update_task.rb

require 'sleeping_king_studios/tasks/apps/applications_task'
require 'sleeping_king_studios/tasks/apps/bundle'
require 'sleeping_king_studios/tasks/apps/bundle/update_runner'

module SleepingKingStudios::Tasks::Apps::Bundle
  # Defines a Thor task for updating gem dependencies for each application.
  class UpdateTask < SleepingKingStudios::Tasks::Task
    include SleepingKingStudios::Tasks::Apps::ApplicationsTask

    def self.description
      'Updates the Ruby gem dependencies for each application.'
    end # class method description

    def call *applications
      filtered = filter_applications(:only => applications)

      gemfiles(filtered).each do |gemfile|
        say %(\nUpdating gems for gemfile "#{gemfile}")
        say '-' * 80
        say "\n"

        update_runner.call(gemfile)
      end # each
    end # method call

    private

    def gemfiles applications
      applications.map { |_, config| config.gemfile }.uniq
    end # method gemfiles

    def update_runner
      @update_runner =
        SleepingKingStudios::Tasks::Apps::Bundle::UpdateRunner.new
    end # method update_runner
  end # class
end # module
