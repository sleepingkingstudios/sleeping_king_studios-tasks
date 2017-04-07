# spec/sleeping_king_studios/tasks/ci/tasks_spec.thor

load 'sleeping_king_studios/tasks/ci/tasks.thor'

require 'common/task_group_examples'

RSpec.describe SleepingKingStudios::Tasks::Ci::Tasks do
  include Spec::Common::TaskGroupExamples

  let(:instance) { described_class.new }

  describe '#rspec' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Ci::RSpec,
      :namespace => 'ci'
end # describe
