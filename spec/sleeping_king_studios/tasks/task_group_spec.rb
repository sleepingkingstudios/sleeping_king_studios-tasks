# spec/sleeping_king_studios/tasks/task_group_spec.rb

require 'thor/runner'

require 'sleeping_king_studios/tasks'

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
  end # class
end # module

RSpec.describe SleepingKingStudios::Tasks::TaskGroup do
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
    shared_examples 'should define the task' do
      it 'should add the task to `thor list`' do
        captured = capture_stdout { Thor::Runner.new.list }
        expect(captured).to satisfy {
          captured.each_line.any? do |line|
            next false unless line.start_with? "#{basename} #{task_name}"

            desc = line.split('#')[1..-1].join('#').strip
            desc = desc[0...-3] if desc.end_with?('...')

            task_definition.description.start_with?(desc)
          end # any?
        } # end satisfy
      end # it

      it 'should add the full task to `thor help`' do
        captured =
          capture_stdout do
            Thor::Runner.new.help task_name
          end # capture

        expect(captured).to be == help_text
      end # it

      it 'should call an instance of the task class' do
        expect(task_definition).
          to receive(:new).
          with(options).
          and_return(task_instance)

        expect(task_instance).
          to receive(:call).
          with(*args).
          and_return('OK')

        expect(instance.invoke task_name, args, options).
          to be == 'OK'
      end # it
    end # shared_examples

    let(:basename)        { 'rspec' }
    let(:args)            { [:a, :b] }
    let(:options)         { { :silliness => 11 } }
    let(:task_definition) { Spec::Walk }
    let(:task_instance)   { task_definition.new(options) }
    let(:task_name)       { "spec:tasks:#{task_definition.task_name}" }
    let(:help_text) do
      expected = "Usage:\n  #{basename} #{task_name}"
      expected << "\n\n" << task_definition.description << "\n"
    end # let

    around(:example) do |example|
      # rubocop:disable Style/GlobalVars
      begin
        prior        = $thor_runner
        $thor_runner = true

        example.call
      ensure
        $thor_runner = prior
      end # begin-ensure
      # rubocop:enable Style/GlobalVars
    end # around example

    it { expect(described_class).to respond_to(:task).with(1..2).arguments }

    include_examples 'should define the task'

    context 'when the task has method options' do
      let(:task_definition) { Spec::WalkWithOptions }
      let(:help_text) do
        expected = "Usage:\n  #{basename} #{task_name}"
        expected << "\n\nOptions:\n  -s, [--silliness=N]  "
        expected << "\n\n" << task_definition.description << "\n"
      end # let

      include_examples 'should define the task'
    end # context
  end # describe
end # describe
