# spec/sleeping_king_studios/tasks/apps/ci/steps_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/steps'
require 'sleeping_king_studios/tasks/ci/rspec_results'
require 'sleeping_king_studios/tasks/ci/rubocop_results'
require 'sleeping_king_studios/tasks/ci/simplecov_results'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::Steps do
  let(:options)  { { 'quiet' => true } }
  let(:instance) { described_class.new(options) }
  let(:applications) do
    {
      'admin'   => {},
      'public'  => {},
      'reports' => {}
    } # end applications
  end # let
  let(:config) do
    applications.each.with_object({}) do |(name, data), hsh|
      tools = SleepingKingStudios::Tools::Toolbelt.instance
      data  = tools.hash.convert_keys_to_symbols(data)

      hsh[name] = SleepingKingStudios::Tasks::Apps::AppConfiguration.new(data)
    end # each
  end # let

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
        let!(:steps_runner) do
          SleepingKingStudios::Tasks::Apps::Ci::StepsRunner.new(options)
        end # let
        let!(:global_runner) do
          opts = options.merge 'global' => true

          SleepingKingStudios::Tasks::Apps::Ci::StepsRunner.new(opts)
        end # let
        let(:reporter) do
          SleepingKingStudios::Tasks::Apps::Ci::ResultsReporter.new(instance)
        end # let

        before(:example) do
          allow(instance).to receive(:applications).and_return(config)

          allow(instance).
            to receive(:filter_applications).
            with(:only => only).
            and_return(config)

          allow(SleepingKingStudios::Tasks::Apps::Ci::StepsRunner).
            to receive(:new) do |opts|
              expect(opts).to be >= options

              opts['global'] ? global_runner : steps_runner
            end # receive

          allow(SleepingKingStudios::Tasks::Apps::Ci::ResultsReporter).
            to receive(:new).
            with(instance).
            and_return(reporter)
        end # before example

        it do
          applications.each_key do |name|
            expect(steps_runner).
              to receive(:call).
              with(name).
              and_return(expected_results[name])
          end # each

          expect(global_runner).
            to receive(:call).
            and_return(global_results)

          expect(reporter).to receive(:call).with(expected_results)

          expect(instance.call(*only)).to be == expected_results
        end # it
      end # describe
    end # shared_examples

    let(:only) { [] }
    let(:global_results) do
      {
        'SimpleCov' => SleepingKingStudios::Tasks::Ci::SimpleCovResults.new(
          double(
            'results',
            :covered_percent => 97.0,
            :covered_lines   => 97,
            :missed_lines    => 3,
            :total_lines     => 100
          ) # end results
        ) # end SimpleCov results
      } # end global results
    end # let
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
              ), # end RSpec results
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 5,
                'offense_count'        => 3
              ) # end RuboCop results
          }, # end admin
        'public' =>
          {
            'RSpec' =>
              SleepingKingStudios::Tasks::Ci::RSpecResults.new(
                'duration'      => 0.5,
                'example_count' => 2,
                'pending_count' => 1,
                'failure_count' => 0
              ), # end RSpec results
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 10,
                'offense_count'        => 1
              ) # end RuboCop results
          }, # end public
        'reports' =>
          {
            'RSpec' =>
              SleepingKingStudios::Tasks::Ci::RSpecResults.new(
                'duration'      => 1.5,
                'example_count' => 6,
                'pending_count' => 0,
                'failure_count' => 0
              ), # end RSpec results
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 15,
                'offense_count'        => 0
              ) # end RuboCop results
          }, # end reports
        'Totals' =>
          {
            'RSpec' =>
              SleepingKingStudios::Tasks::Ci::RSpecResults.new(
                'duration'      => 3.0,
                'example_count' => 11,
                'pending_count' => 2,
                'failure_count' => 1
              ), # end RSpec results
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 30,
                'offense_count'        => 4
              ), # end RuboCop results
            'SimpleCov' => global_results['SimpleCov']
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
