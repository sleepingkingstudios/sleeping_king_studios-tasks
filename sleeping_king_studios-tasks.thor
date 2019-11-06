# sleeping_king_studios-tasks.thor

begin
  require 'byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
  # Probably don't need this.
end # begin-rescue

$LOAD_PATH << 'lib'

require 'sleeping_king_studios/tasks'

SleepingKingStudios::Tasks.configure do |config|
  config.ci do |ci|
    ci.steps =
      if ENV['CI']
        %i[rspec rspec_each rubocop simplecov]
      else
        %i[rspec rubocop simplecov]
      end # if-else
  end # ci

  config.file do |file|
    file.template_paths =
      [
        '../sleeping_king_studios-templates/lib',
        file.class.default_template_path
      ] # end template paths
  end # file
end # configure

load 'sleeping_king_studios/tasks/ci/tasks.thor'
load 'sleeping_king_studios/tasks/file/tasks.thor'
