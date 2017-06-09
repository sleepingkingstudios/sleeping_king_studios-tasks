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
      expect(described_class).to have_reader(:task_name).with_value 'rspec'
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
        'pending_count' => 2,
        'error_count'   => 0
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
      let(:expected_env) { { :coverage => false } }
      let(:expected_files) do
        ['spec/foo', 'spec/bar', 'spec/wibble/wobble_spec.rb']
      end # let

      include_examples 'should call an RSpec runner'

      describe 'with --coverage=true' do
        let(:options)      { { 'coverage' => true } }
        let(:expected_env) { {} }

        include_examples 'should call an RSpec runner'
      end # describe
    end # describe

    describe 'with --coverage=false' do
      let(:options)      { { 'coverage' => false } }
      let(:expected_env) { { :coverage => false } }

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

    context 'when a gemfile is specified via the environment' do
      let(:bundled_gemfile) { 'path/to/bundle' }
      let(:expected_env)    { { :bundle_gemfile => bundled_gemfile } }

      around(:example) do |example|
        begin
          prior                 = ENV['BUNDLE_GEMFILE']
          ENV['BUNDLE_GEMFILE'] = bundled_gemfile

          example.call
        ensure
          ENV['BUNDLE_GEMFILE'] = prior
        end # begin-ensure
      end # around example

      include_examples 'should call an RSpec runner'

      describe 'with --gemfile=GEMFILE' do
        let(:options)      { { 'gemfile' => 'path/to/gemfile' } }
        let(:expected_env) { { :bundle_gemfile => 'path/to/gemfile' } }

        include_examples 'should call an RSpec runner'
      end # describe
    end # context
  end # describe
end # describe
