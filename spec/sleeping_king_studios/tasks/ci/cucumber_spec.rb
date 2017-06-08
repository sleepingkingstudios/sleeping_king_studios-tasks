# spec/sleeping_king_studios/tasks/ci/cucumber_spec.rb

require 'sleeping_king_studios/tasks/ci/cucumber'

RSpec.describe SleepingKingStudios::Tasks::Ci::Cucumber do
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

        results = instance.call(*expected_files)

        expect(results).to be_a expected_class
        expect(results).to be == expected
      end # it
    end # shared_examples

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
      let(:expected_files) do
        ['spec/foo', 'spec/bar', 'spec/wibble/wobble_spec.rb']
      end # let

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
end # describe
