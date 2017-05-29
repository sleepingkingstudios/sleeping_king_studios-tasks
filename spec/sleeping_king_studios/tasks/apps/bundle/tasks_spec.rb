# spec/sleeping_king_studios/tasks/apps/bundle/tasks_spec.rb

load 'sleeping_king_studios/tasks/apps/bundle/tasks.thor'

require 'common/task_group_examples'

RSpec.describe SleepingKingStudios::Tasks::Apps::Bundle::Tasks do
  include Spec::Common::TaskGroupExamples

  let(:instance) { described_class.new }

  describe '#install' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Apps::Bundle::Install,
      :namespace => 'apps:bundle'

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Apps::Bundle::Update,
      :namespace => 'apps:bundle'
  end # describe
end # describe
