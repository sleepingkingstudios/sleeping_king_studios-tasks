# spec/sleeping_king_studios/tasks/ci/rspec_spec.rb

require 'sleeping_king_studios/tasks/ci/rspec'

RSpec.describe SleepingKingStudios::Tasks::Ci::RSpec do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the RSpec test suite.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value :rspec
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should call an RSpec runner' do
      it 'should call an RSpec runner' do
        allow(SleepingKingStudios::Tasks::Ci::RSpecRunner).
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
      end # it
    end # shared_examples

    let(:expected_files)   { [] }
    let(:expected_env)     { {} }
    let(:expected_options) { ['--color', '--tty', '--format=documentation'] }
    let(:expected_class)   { SleepingKingStudios::Tasks::Ci::RSpecResults }
    let(:expected) do
      {
        'duration'      => 1.0,
        'example_count' => 6,
        'failure_count' => 1,
        'pending_count' => 2
      } # end expected
    end # let
    let(:runner) do
      SleepingKingStudios::Tasks::Ci::RSpecRunner.
        new(
          :env     => expected_env,
          :options => expected_options
        ) # end new
    end # let

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call an RSpec runner'

    describe 'with files' do
      let(:expected_files) do
        ['spec/foo', 'spec/bar', 'spec/wibble/wobble_spec.rb']
      end # let

      include_examples 'should call an RSpec runner'
    end # describe

    describe 'with --gemfile=GEMFILE' do
      let(:options)      { { 'gemfile' => 'path/to/gemfile' } }
      let(:expected_env) { { :bundle_gemfile => 'path/to/gemfile' } }

      include_examples 'should call an RSpec runner'
    end # describe

    describe 'with --quiet=true' do
      let(:options)          { { 'quiet' => true } }
      let(:expected_options) { ['--color', '--tty'] }

      include_examples 'should call an RSpec runner'
    end # describe

    describe 'with --raw=true' do
      let(:options)        { { 'raw' => true } }
      let(:expected_class) { Hash }

      include_examples 'should call an RSpec runner'
    end # describe
  end # describe
end # describe
