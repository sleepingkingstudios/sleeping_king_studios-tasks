# lib/sleeping_king_studios/tasks/configuration.rb

require 'sleeping_king_studios/tools/toolbox/configuration'

require 'sleeping_king_studios/tasks'

module SleepingKingStudios::Tasks
  # Task configuration options, grouped by namespace.
  class Configuration < SleepingKingStudios::Tools::Toolbox::Configuration
    namespace :file do
      def self.default_template_path
        ::File.
          join(SleepingKingStudios::Tasks.gem_path, 'file', 'templates').
          freeze
      end # method default_template_path

      option :template_paths, :default => [default_template_path]
    end # namespace
  end # class
end # module
