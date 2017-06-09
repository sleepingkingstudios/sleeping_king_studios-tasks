# spec/sleeping_king_studios/tasks/apps/ci/tasks_spec.rb

load 'sleeping_king_studios/tasks/apps/ci/tasks.thor'

require 'common/task_group_examples'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::Tasks do
  include Spec::Common::TaskGroupExamples

  let(:instance) { described_class.new }

  describe '#rspec' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Apps::Ci::RSpecTask,
      :namespace => 'apps:ci'
  end # describe

  describe '#rubocop' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Apps::Ci::RuboCopTask,
      :namespace => 'apps:ci'
  end # describe

  describe '#steps' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Apps::Ci::StepsTask,
      :namespace => 'apps:ci'
  end # describe
end # describe
