# lib/sleeping_king_studios/tasks/apps/app_configuration.rb

require 'sleeping_king_studios/tools/toolbox/configuration'

require 'sleeping_king_studios/tasks/apps'

module SleepingKingStudios::Tasks::Apps
  # Application configuration options.
  class AppConfiguration < SleepingKingStudios::Tools::Toolbox::Configuration
    namespace :ci do
      option :rspec, :default => {}

      option :rubocop, :default => {}

      option :simplecov, :default => {}

      option :steps, :default =>
        ->() { SleepingKingStudios::Tasks.configuration.apps.ci.steps }

      define_method :steps_with_options do
        steps.each.with_object({}) do |step, hsh|
          value = send(step)

          next hsh[step] = false if value == false

          default   =
            SleepingKingStudios::Tasks.configuration.apps.ci.send(step)
          hsh[step] = default.merge(value)
        end # each
      end # method steps_with_options
    end # namespace

    define_method :default_source_files do
      files = [
        "apps/#{short_name}",
        "apps/#{short_name}.rb",
        "lib/#{short_name}",
        "lib/#{short_name}.rb"
      ] # end files

      files.select { |path| File.exist?(path) }
    end # method default_source_files

    define_method :default_spec_files do
      files = ["apps/#{short_name}/spec", "spec/#{short_name}"]

      files.select { |path| File.exist?(path) }
    end # method default_spec_files

    define_method :short_name do
      # rubocop:disable Style/RedundantSelf
      tools.str.underscore(self.name.gsub(/\s+/, '_'))
      # rubocop:enable Style/RedundantSelf
    end # define_method

    define_method :tools do
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools

    option :gemfile, :default => 'Gemfile'

    option :name

    option :source_files, :default => ->() { default_source_files }

    option :spec_files, :default => ->() { default_spec_files }
  end # module
end # module
