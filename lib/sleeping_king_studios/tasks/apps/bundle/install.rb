# lib/sleeping_king_studios/tasks/apps/bundle/install.rb

require 'sleeping_king_studios/tasks/apps/applications_task'
require 'sleeping_king_studios/tasks/apps/bundle'
require 'sleeping_king_studios/tasks/apps/bundle/install_runner'

module SleepingKingStudios::Tasks::Apps::Bundle
  # Defines a Thor task for installing gem dependencies for each application.
  class Install < SleepingKingStudios::Tasks::Apps::ApplicationsTask
    def self.description
      'Installs the Ruby gem dependencies for each application.'
    end # class method description

    def call *applications
      gemfiles(applications).each do |gemfile|
        say %(\nInstalling gems for gemfile "#{gemfile}")
        say '-' * 80
        say "\n"

        install_runner.call(gemfile)
      end # each
    end # method call

    private

    def gemfiles only
      filtered = applications

      unless only.empty?
        normalized = only.map(&:to_s)
        filtered   = filtered.select { |key, _| normalized.include?(key) }
      end # unless

      filtered.map do |_, config|
        config.fetch('gemfile', 'Gemfile')
      end. # map
        uniq
    end # method gemfiles

    def install_runner
      @install_runner =
        SleepingKingStudios::Tasks::Apps::Bundle::InstallRunner.new
    end # method install_runner
  end # module
end # module
