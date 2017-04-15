# sleeping_king_studios-tasks.thor

begin
  require 'byebug'
rescue LoadError
  # Probably don't need this.
end # begin-rescue

$: << 'lib'

require 'sleeping_king_studios/tasks'

SleepingKingStudios::Tasks.configure do |config|
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
