# spec/sleeping_king_studios/tasks/task_group_spec.rb

require 'thor/runner'

require 'sleeping_king_studios/tasks'

require 'common/task_group_examples'

module Spec
  class Walk < SleepingKingStudios::Tasks::Task
    def self.description
      'A rather silly walk.'
    end # class method description
  end # class

  class WalkWithOptions < SleepingKingStudios::Tasks::Task
    def self.description
      'A walk with a configurable level of silliness.'
    end # class method description

    option :silliness,
      :aliases => '-s',
      :type    => :numeric
  end # class

  class Tasks < SleepingKingStudios::Tasks::TaskGroup
    task Walk
    task WalkWithOptions
    task Walk, :as => :silly_walk
  end # class
end # module

RSpec.describe SleepingKingStudios::Tasks::TaskGroup do
  include Spec::Common::TaskGroupExamples

  let(:described_class) { Class.new(super()) }
  let(:instance)        { described_class.new }

  def capture_stdout
    buffer  = StringIO.new
    prior   = $stdout
    $stdout = buffer

    yield

    buffer.string
  ensure
    $stdout = prior
  end # method capture_stdout

  it { expect(described_class).to be < ::Thor }

  describe '::task' do
    let(:args)    { [:a, :b] }
    let(:options) { { :silliness => 11 } }

    it { expect(described_class).to respond_to(:task).with(1..2).arguments }

    include_examples 'should define task',
      Spec::Walk,
      :namespace => 'spec:tasks'

    context 'when the task has method options' do
      include_examples 'should define task',
        Spec::WalkWithOptions,
        :namespace => 'spec:tasks'
    end # context

    describe 'with :as => name' do
      include_examples 'should define task',
        Spec::Walk,
        :as        => :silly_walk,
        :namespace => 'spec:tasks'
    end # describe
  end # describe
end # describe
