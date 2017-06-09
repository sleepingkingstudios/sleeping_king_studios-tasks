# spec/sleeping_king_studios/tasks/ci/tasks_spec.thor

load 'sleeping_king_studios/tasks/ci/tasks.thor'

require 'common/task_group_examples'

RSpec.describe SleepingKingStudios::Tasks::Ci::Tasks do
  include Spec::Common::TaskGroupExamples

  let(:instance) { described_class.new }

  describe '#cucumber' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Ci::CucumberTask,
      :namespace => 'ci'
  end # describe

  describe '#rspec' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Ci::RSpecTask,
      :namespace => 'ci'
  end # describe

  describe '#rspec_each' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Ci::RSpecEachTask,
      :namespace => 'ci'
  end # describe

  describe '#rubocop' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Ci::RuboCopTask,
      :namespace => 'ci'
  end # describe

  describe '#steps' do
    let(:args) { ['path/to/file'] }

    include_examples 'should define task',
      SleepingKingStudios::Tasks::Ci::StepsTask,
      :namespace => 'ci'
  end # describe
end # describe
