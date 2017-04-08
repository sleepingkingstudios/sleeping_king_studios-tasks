# spec/sleeping_king_studios/tasks/ci/rubocop_spec.rb

require 'sleeping_king_studios/tasks/ci/rubocop'

RSpec.describe SleepingKingStudios::Tasks::Ci::RuboCop do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the RuboCop linter.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value :rubocop
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should call a RuboCop runner' do
      it 'should call a RuboCop runner' do
        allow(SleepingKingStudios::Tasks::Ci::RuboCopRunner).
          to receive(:new).
          with(:options => expected_options).
          and_return(runner)

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
    let(:expected_options) { ['--color', '--format=progress'] }
    let(:expected_class)   { SleepingKingStudios::Tasks::Ci::RuboCopResults }
    let(:expected) do
      {
        'inspected_file_count' => 1.0,
        'offense_count'        => 3
      } # end expected
    end # let
    let(:runner) do
      SleepingKingStudios::Tasks::Ci::RuboCopRunner.
        new(:options => expected_options)
    end # let

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call a RuboCop runner'

    describe 'with files' do
      let(:expected_files) do
        ['spec/foo', 'spec/bar', 'spec/wibble/wobble_spec.rb']
      end # let

      include_examples 'should call a RuboCop runner'
    end # describe

    describe 'with --quiet=true' do
      let(:options)          { { 'quiet' => true } }
      let(:expected_options) { ['--color'] }

      include_examples 'should call a RuboCop runner'
    end # describe

    describe 'with --raw=true' do
      let(:options)        { { 'raw' => true } }
      let(:expected_class) { Hash }

      include_examples 'should call a RuboCop runner'
    end # describe
  end # describe
end # describe
