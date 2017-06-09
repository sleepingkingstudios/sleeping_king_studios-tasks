# spec/sleeping_king_studios/tasks/task_spec.rb

require 'sleeping_king_studios/tasks'

RSpec.describe SleepingKingStudios::Tasks::Task do
  let(:described_class) { Class.new(super()) }
  let(:options)         { { 'silliness' => 11 } }
  let(:instance)        { described_class.new options }

  def capture_stdout
    prior   = $stdout
    $stdout = StringIO.new

    yield

    $stdout.string
  ensure
    $stdout = prior
  end # method capture_stdout

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end # method tools

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::description' do
    it 'should define the class reader' do
      expect(described_class).
        to have_reader(:description).
        with_value(an_instance_of String)
    end # it
  end # describe

  describe '::option' do
    let(:option_name)   { :silliness }
    let(:option_params) { { :type => :numeric } }

    it 'should define the class method' do
      expect(described_class).to respond_to(:option).with(2).arguments
    end # it

    it 'should update the options' do
      expect { described_class.option option_name, option_params }.
        to change(described_class, :options).
        to include(option_name => option_params)
    end # it

    it 'should define the accessor' do
      described_class.option option_name, option_params

      expect(instance).
        to have_reader(option_name).
        with_value(options[option_name.to_s])
    end # it

    describe 'with :type => :boolean' do
      let(:option_name)   { :'extra-silly' }
      let(:option_params) { { :type => :boolean } }
      let(:options)       { { 'extra-silly' => true } }

      it 'should define the predicate' do
        expected_name = tools.string.underscore(option_name)

        described_class.option option_name, option_params

        expect(instance).
          to have_predicate(expected_name).
          with_value(options[option_name.to_s])
      end # it
    end # describe
  end # describe

  describe '::options' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:options).with_value({})
    end # it
  end # describe

  describe '::task_name' do
    let(:class_name) { 'Ministry::Silly::Walks' }

    before(:example) do
      allow(described_class).to receive(:name).and_return(class_name)
    end # before example

    it 'should define the class reader' do
      expect(described_class).
        to have_reader(:task_name).
        with_value('walks')
    end # it

    context 'when the task name ends with Task' do
      let(:class_name) { 'Ministry::Silly::WalksTask' }

      it { expect(described_class.task_name).to be == 'walks' }
    end # context
  end # describe

  describe '#call' do
    it { expect(instance).to respond_to(:call).with_unlimited_arguments }
  end # method describe

  describe '#mute?' do
    it { expect(instance).to have_predicate(:mute?).with_value(false) }

    it { expect(instance).to alias_method(:mute?).as(:muted?) }
  end # describe

  describe '#mute!' do
    it { expect(instance).to respond_to(:mute!).with(0).arguments }

    it 'should mute the task' do
      expect { instance.mute! }.to change(instance, :mute?).to be true
    end # it
  end # describe

  describe '#options' do
    include_examples 'should have reader', :options, ->() { be == options }
  end # describe

  describe '#say' do
    let(:message) { 'Greetings, programs!' }

    it 'should define the method' do
      expect(instance).to respond_to(:say, true).with(0..3).arguments
    end # it

    it 'should print the message' do
      captured = capture_stdout { instance.say message }

      expect(captured).to be == "#{message}\n"
    end # it

    context 'when the task is muted' do
      before(:example) do
        allow(instance).to receive(:mute?).and_return(true)
      end # before example

      it 'should not print the message' do
        captured = capture_stdout { instance.say message }

        expect(captured).to be_empty
      end # it
    end # context
  end # describe
end # describe
