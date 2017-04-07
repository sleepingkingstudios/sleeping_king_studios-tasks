# sleeping_king_studios-tasks.thor

begin
  require 'byebug'
rescue LoadError
  # Probably don't need this.
end # begin-rescue

$: << 'lib'

load 'sleeping_king_studios/tasks/ci/tasks.thor'
load 'sleeping_king_studios/tasks/file/tasks.thor'
