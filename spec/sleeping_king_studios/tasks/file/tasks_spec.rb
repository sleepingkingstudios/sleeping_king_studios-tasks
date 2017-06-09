# spec/sleeping_king_studios/tasks/file/tasks_spec.rb

load 'sleeping_king_studios/tasks/file/tasks.thor'

require 'common/task_group_examples'

RSpec.describe SleepingKingStudios::Tasks::File::Tasks do
  include Spec::Common::TaskGroupExamples

  let(:instance) { described_class.new }

  describe '#new' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::File::NewTask,
      :namespace => 'file'
  end # describe
end # describe
