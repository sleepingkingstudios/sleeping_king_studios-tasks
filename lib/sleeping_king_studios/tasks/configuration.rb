# lib/sleeping_king_studios/tasks/configuration.rb

require 'sleeping_king_studios/tools/toolbox/configuration'

require 'sleeping_king_studios/tasks'

module SleepingKingStudios::Tasks
  # Task configuration options, grouped by namespace.
  class Configuration < SleepingKingStudios::Tools::Toolbox::Configuration
    namespace :ci do
      option :rspec, :default =>
        {
          :require => 'sleeping_king_studios/tasks/ci/rspec',
          :class   => 'SleepingKingStudios::Tasks::Ci::RSpec',
          :title   => 'RSpec'
        } # end rspec

      option :rubocop, :default =>
        {
          :require => 'sleeping_king_studios/tasks/ci/rubocop',
          :class   => 'SleepingKingStudios::Tasks::Ci::RuboCop',
          :title   => 'RuboCop'
        } # end rspec

      option :simplecov, :default =>
        {
          :require => 'sleeping_king_studios/tasks/ci/simplecov',
          :class   => 'SleepingKingStudios::Tasks::Ci::SimpleCov',
          :title   => 'SimpleCov'
        } # end rspec

      option :steps, :default => %i(rspec rubocop simplecov)

      define_method :steps_with_options do
        steps.each.with_object({}) do |step, hsh|
          hsh[step] = send(step)
        end # each
      end # method steps_with_options
    end # namespace

    namespace :file do
      def self.default_template_path
        relative_path =
          ::File.join(
            SleepingKingStudios::Tasks.gem_path,
            'lib',
            'sleeping_king_studios',
            'tasks',
            'file',
            'templates'
          ) # end join

        ::File.expand_path(relative_path).freeze
      end # method default_template_path

      option :template_paths, :default => [default_template_path]
    end # namespace
  end # class
end # module
