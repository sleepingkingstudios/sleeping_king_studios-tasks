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
    shared_examples 'should call an RSpec runner for each application' do
      describe 'should call an RSpec runner for each application' do
        before(:example) do
          allow(instance).to receive(:applications).and_return(applications)

          allow(SleepingKingStudios::Tasks::Ci::RSpecRunner).
            to receive(:new).
            with(:options => expected_options).
            and_return(runner)

          allow(SleepingKingStudios::Tasks::Apps::Ci::ResultsReporter).
            to receive(:new).
            with(instance).
            and_return(reporter)
        end # before example

        it do
          expected_applications.each do |name, config|
            gemfile        = config.fetch('gemfile', 'Gemfile')
            expected_env   = { :bundle_gemfile => gemfile }
            expected_files = ["path/to/#{name}/spec"]

            expect(instance).
              to receive(:spec_directories).
              with(name, config).
              and_return(expected_files)

            expect(runner).
              to receive(:call).
              with(:env => expected_env, :files => expected_files).
              and_return(results[name]['RSpec'].to_h)
          end # each

          expect(reporter).to receive(:call).with(expected_results)

          instance.call(*only)
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
    let(:results) do
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
      } # end results
    end # let
    let(:only) { [] }
    let(:expected_applications) { applications }
    let(:expected_results)      { results }
    let(:expected_options)      { ['--color', '--tty'] }
    let(:expected) do
      {
        'duration'      => 1.0,
        'example_count' => 6,
        'failure_count' => 1,
        'pending_count' => 2
      } # end expected
    end # let
    let(:reporter) do
      SleepingKingStudios::Tasks::Apps::Ci::ResultsReporter.new(instance)
    end # let
    let(:runner) do
      SleepingKingStudios::Tasks::Ci::RSpecRunner.
        new(:options => expected_options)
    end # let

    before(:example) do
      allow(instance).to receive(:applications).and_return(applications)
    end # before example

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call an RSpec runner for each application'

    describe 'with applications' do
      let(:only) { %w(public) }
      let(:expected_applications) do
        applications.select { |key, _| only.include?(key) }
      end # let
      let(:expected_results) do
        hsh =
          results.select { |key, _| [*only, 'Totals'].include?(key) }

        hsh['Totals'] = hsh['public']

        hsh
      end # let

      include_examples 'should call an RSpec runner for each application'
    end # describe
  end # describe
end # describe
