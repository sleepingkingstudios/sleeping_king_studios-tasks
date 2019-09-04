# lib/sleeping_king_studios/tasks/configuration.rb

require 'sleeping_king_studios/tools/toolbox/configuration'

require 'sleeping_king_studios/tasks'

module SleepingKingStudios::Tasks
  # rubocop:disable Metrics/ClassLength

  # Task configuration options, grouped by namespace.
  class Configuration < SleepingKingStudios::Tools::Toolbox::Configuration
    # rubocop:disable Metrics/BlockLength
    namespace :apps do
      namespace :ci do
        option :rspec, :default =>
          {
            :require => 'sleeping_king_studios/tasks/apps/ci/rspec_wrapper',
            :class   => 'SleepingKingStudios::Tasks::Apps::Ci::RSpecWrapper',
            :title   => 'RSpec'
          } # end rspec

        option :rubocop, :default =>
          {
            :require => 'sleeping_king_studios/tasks/apps/ci/rubocop_wrapper',
            :class   => 'SleepingKingStudios::Tasks::Apps::Ci::RuboCopWrapper',
            :title   => 'RuboCop'
          } # end rspec

        option :simplecov, :default =>
          {
            :require => 'sleeping_king_studios/tasks/apps/ci/simplecov_task',
            :class   => 'SleepingKingStudios::Tasks::Apps::Ci::SimpleCovTask',
            :title   => 'SimpleCov',
            :global  => true
          } # end rspec

        option :steps, :default => %i(rspec rubocop simplecov)

        define_method :steps_with_options do
          steps.each.with_object({}) do |step, hsh|
            hsh[step] = send(step)
          end # each
        end # method steps_with_options
      end # namespace

      option :config_file, :default => 'applications.yml'
    end # namespace
    # rubocop:enable Metrics/BlockLength

    # rubocop:disable Metrics/BlockLength
    namespace :ci do
      option :cucumber, :default =>
        {
          :require       => 'sleeping_king_studios/tasks/ci/cucumber_task',
          :class         => 'SleepingKingStudios::Tasks::Ci::CucumberTask',
          :title         => 'Cucumber',
          :default_files => ['step_definitions', 'step_definitions.rb']
        } # end cucumber

      option :eslint, :default =>
        {
          :class         => 'SleepingKingStudios::Tasks::Ci::EslintTask',
          :default_files => '"**/*.js"',
          :require       => 'sleeping_king_studios/tasks/ci/eslint_task',
          :title         => 'ESLint'
        }

      option :jest, :default =>
        {
          :class   => 'SleepingKingStudios::Tasks::Ci::JestTask',
          :require => 'sleeping_king_studios/tasks/ci/jest_task',
          :title   => 'Jest',
          :verbose => false
        }

      option :rspec, :default =>
        {
          :require => 'sleeping_king_studios/tasks/ci/rspec_task',
          :class   => 'SleepingKingStudios::Tasks::Ci::RSpecTask',
          :title   => 'RSpec',
          :format  => 'documentation'
        } # end rspec

      option :rspec_each, :default =>
        {
          :require => 'sleeping_king_studios/tasks/ci/rspec_each_task',
          :class   => 'SleepingKingStudios::Tasks::Ci::RSpecEachTask',
          :title   => 'RSpec (Each)',
          :format  => nil
        } # end rspec

      option :rubocop, :default =>
        {
          :require => 'sleeping_king_studios/tasks/ci/rubocop_task',
          :class   => 'SleepingKingStudios::Tasks::Ci::RuboCopTask',
          :title   => 'RuboCop'
        } # end rspec

      option :simplecov, :default =>
        {
          :require => 'sleeping_king_studios/tasks/ci/simplecov_task',
          :class   => 'SleepingKingStudios::Tasks::Ci::SimpleCovTask',
          :title   => 'SimpleCov'
        } # end rspec

      option :steps, :default => %i(rspec rubocop simplecov)

      define_method :steps_with_options do
        steps.each.with_object({}) do |step, hsh|
          hsh[step] = send(step)
        end # each
      end # method steps_with_options
    end # namespace
    # rubocop:enable Metrics/BlockLength

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
  # rubocop:enable Metrics/ClassLength
end # module
