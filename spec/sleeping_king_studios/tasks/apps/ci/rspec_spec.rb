# spec/sleeping_king_studios/tasks/apps/ci/rspec_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/rspec'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::RSpec do
  let(:options)  { { 'quiet' => true } }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the RSpec test suite for each application.' }

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
    shared_examples 'should call the step runner with only => "rspec"' do
      describe 'should call the step runner with only => "rspec"' do
        let(:expected_options) { options.merge 'only' => %w(rspec) }
        let(:expected_results) { double('results') }
        let(:step_runner) do
          SleepingKingStudios::Tasks::Apps::Ci::Steps.new(expected_options)
        end # let

        it do
          expect(SleepingKingStudios::Tasks::Apps::Ci::Steps).
            to receive(:new).
            with(expected_options).
            and_return(step_runner)

          expect(step_runner).
            to receive(:call).
            with(*(only.empty? ? [no_args] : only)).
            and_return(expected_results)

          expect(instance.call(*only)).to be expected_results
        end # it
      end # describe
    end # shared_examples

    let(:only) { [] }

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call the step runner with only => "rspec"'

    describe 'with applications' do
      let(:only) { %w(public) }

      include_examples 'should call the step runner with only => "rspec"'
    end # describe
  end # describe
end # describe
