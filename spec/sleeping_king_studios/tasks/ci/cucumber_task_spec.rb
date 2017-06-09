# spec/sleeping_king_studios/tasks/ci/cucumber_task_spec.rb

require 'sleeping_king_studios/tasks/ci/cucumber_task'

RSpec.describe SleepingKingStudios::Tasks::Ci::CucumberTask do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the Cucumber feature suite.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'cucumber'
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should call a Cucumber runner' do
      before(:example) do
        allow(SleepingKingStudios::Tasks::Ci::CucumberRunner).
          to receive(:new).
          with(:options => expected_options).
          and_return(runner)
      end # before example

      it 'should call a Cucumber runner' do
        expect(runner).
          to receive(:call).
          with(:files => expected_files).
          and_return(expected)

        results = instance.call(*actual_files)

        expect(results).to be_a expected_class
        expect(results).to be == expected
      end # it
    end # shared_examples

    let(:actual_files)     { [] }
    let(:expected_files)   { [] }
    let(:expected_options) { ['--color', '--format=pretty'] }
    let(:expected_class)   { SleepingKingStudios::Tasks::Ci::CucumberResults }
    let(:expected) do
      {
        'scenario_count'     => 3,
        'failing_scenarios'  => [],
        'pending_scenarios'  => [],
        'step_count'         => 3,
        'failing_step_count' => 0,
        'pending_step_count' => 0,
        'duration'           => 0.3
      } # end expected
    end # let
    let(:runner) do
      SleepingKingStudios::Tasks::Ci::CucumberRunner.
        new(:options => expected_options)
    end # let

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call a Cucumber runner'

    describe 'with files' do
      let(:default_files) { ['path/to/file', 'path/to/directory'] }
      let(:actual_files) do
        ['spec/foo', 'spec/bar', 'spec/wibble/wobble_spec.rb']
      end # let
      let(:expected_files) do
        [*actual_files, *default_files]
      end # let

      before(:example) do
        allow(instance).to receive(:default_files).and_return(default_files)
      end # before example

      include_examples 'should call a Cucumber runner'
    end # describe

    describe 'with --quiet=true' do
      let(:options)          { { 'quiet' => true } }
      let(:expected_options) { ['--color'] }

      include_examples 'should call a Cucumber runner'
    end # describe

    describe 'with --raw=true' do
      let(:options)        { { 'raw' => true } }
      let(:expected_class) { Hash }

      include_examples 'should call a Cucumber runner'
    end # describe
  end # describe

  describe '#default_files' do
    let(:configuration) do
      config = SleepingKingStudios::Tasks::Configuration.new

      config.ci.cucumber = config.ci.cucumber.merge('default_files' => expected)

      config
    end # let
    let(:expected) { ['path/to/file', 'path/to/directory'] }

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:default_files)

      expect(instance).to respond_to(:default_files, true).with(0).arguments
    end # it

    it 'should delegate to the configuration' do
      allow(SleepingKingStudios::Tasks).
        to receive(:configuration).
        and_return(configuration)

      expect(instance.send :default_files).to be == expected
    end # it
  end # describe
end # describe
