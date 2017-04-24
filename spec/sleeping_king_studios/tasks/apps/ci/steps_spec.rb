# spec/sleeping_king_studios/tasks/apps/ci/steps_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/steps'
require 'sleeping_king_studios/tasks/ci/rspec_results'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::Steps do
  let(:options)  { { 'quiet' => true } }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the configured steps for each application.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'steps'
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should run each step for each application' do
      describe 'should run each step for each application' do
        let(:runner) do
          SleepingKingStudios::Tasks::Apps::Ci::StepsRunner.new(options)
        end # let
        let(:reporter) do
          SleepingKingStudios::Tasks::Apps::Ci::ResultsReporter.new(instance)
        end # let

        before(:example) do
          allow(instance).to receive(:applications).and_return(applications)

          allow(instance).
            to receive(:filter_applications).
            with(:only => only).
            and_return(applications)

          allow(SleepingKingStudios::Tasks::Apps::Ci::StepsRunner).
            to receive(:new).
            with(options).
            and_return(runner)

          allow(SleepingKingStudios::Tasks::Apps::Ci::ResultsReporter).
            to receive(:new).
            with(instance).
            and_return(reporter)
        end # before example

        it do
          applications.each_key do |name|
            expect(runner).
              to receive(:call).
              with(name).
              and_return(expected_results[name])
          end # each

          expect(reporter).to receive(:call).with(expected_results)

          expect(instance.call(*only)).to be == expected_results
        end # it
      end # describe
    end # shared_examples

    let(:applications) do
      {
        'admin'   => {},
        'public'  => {},
        'reports' => {}
      } # end applications
    end # let
    let(:only) { [] }
    let(:expected_results) do
      {
        'admin' =>
          {
            'RSpec' =>
              SleepingKingStudios::Tasks::Ci::RSpecResults.new(
                'duration'      => 1.0,
                'example_count' => 3,
                'pending_count' => 1,
                'failure_count' => 1
              ) # end RSpec results
          }, # end admin
        'public' =>
          {
            'RSpec' =>
              SleepingKingStudios::Tasks::Ci::RSpecResults.new(
                'duration'      => 0.5,
                'example_count' => 2,
                'pending_count' => 1,
                'failure_count' => 0
              ) # end RSpec results
          }, # end public
        'reports' =>
          {
            'RSpec' =>
              SleepingKingStudios::Tasks::Ci::RSpecResults.new(
                'duration'      => 1.5,
                'example_count' => 6,
                'pending_count' => 0,
                'failure_count' => 0
              ) # end RSpec results
          }, # end reports
        'Totals' =>
          {
            'RSpec' =>
              SleepingKingStudios::Tasks::Ci::RSpecResults.new(
                'duration'      => 3.0,
                'example_count' => 11,
                'pending_count' => 2,
                'failure_count' => 1
              ) # end RSpec results
          } # end totals
      } # end expected_results
    end # let

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should run each step for each application'

    describe 'with applications' do
      let(:only) { %w(public) }

      include_examples 'should run each step for each application'
    end # describe
  end # describe
end # describe
