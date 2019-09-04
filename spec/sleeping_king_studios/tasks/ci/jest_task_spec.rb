# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci/jest_task'

RSpec.describe SleepingKingStudios::Tasks::Ci::JestTask do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the Jest test suite.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end
  end

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'jest'
    end
  end

  describe '#call' do
    shared_examples 'should call a Jest runner' do
      it 'should call a Jest runner' do
        allow(SleepingKingStudios::Tasks::Ci::JestRunner).
          to receive(:new).
          with(:env => expected_env, :options => expected_options).
          and_return(runner)

        expect(runner).
          to receive(:call).
          with(:files => expected_files).
          and_return(expected)

        results = instance.call(*expected_files)

        expect(results).to be_a expected_class
        expect(results).to be == expected
      end
    end

    let(:expected_files)  { [] }
    let(:expected_env)    { {} }
    let(:expected_options) do
      %w(--color) << "--verbose=#{!!options['verbose']}"
    end
    let(:expected_class) { SleepingKingStudios::Tasks::Ci::JestResults }
    let(:expected) do
      start_time = Time.new(1982, 7, 9).to_i
      end_time   = start_time + 1000

      {
        'numTotalTests'   => 3,
        'numFailedTests'  => 2,
        'numPendingTests' => 1,
        'startTime'       => start_time,
        'testResults'     => [
          { 'endTime' => end_time }
        ]
      }
    end
    let(:runner) do
      SleepingKingStudios::Tasks::Ci::JestRunner.
        new(
          :env     => expected_env,
          :options => expected_options
        )
    end

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call a Jest runner'

    describe 'with files' do
      let(:expected_files) do
        ['src/foo', 'src/bar', 'src/wibble/wobble.test.js']
      end

      include_examples 'should call a Jest runner'
    end

    describe 'with --verbose=true' do
      let(:options) { { 'verbose' => true } }

      include_examples 'should call a Jest runner'
    end
  end

  describe '#default_verbose' do
    include_examples 'should have private reader',
      :default_verbose,
      ->() { be == SleepingKingStudios::Tasks.configuration.ci.jest[:verbose] }
  end
end
