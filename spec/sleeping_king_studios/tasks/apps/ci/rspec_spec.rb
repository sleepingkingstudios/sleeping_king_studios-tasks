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
            gemfile      = config.fetch('gemfile', 'Gemfile')
            expected_env = { :bundle_gemfile => gemfile }

            expect(instance).
              to receive(:spec_directories).
              with(name, config).
              and_return(expected_files[name])

            next if expected_files[name].empty?

            expect(runner).
              to receive(:call).
              with(:env => expected_env, :files => expected_files[name]).
              and_return(results[name]['RSpec'].to_h)
          end # each

          if options.fetch('report', true)
            expect(reporter).to receive(:call).with(be == expected_results)
          else
            expect(reporter).not_to receive(:call)
          end # if-else

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
    let(:expected_files) do
      {
        'admin'   => ['path/to/admin/spec'],
        'public'  => ['path/to/public/spec'],
        'reports' => ['path/to/reports/spec']
      } # end applications
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

    describe 'with :report => false' do
      let(:options) { super().merge 'report' => false }

      include_examples 'should call an RSpec runner for each application'
    end # describe

    context 'when an application does not have spec files' do
      let(:expected_files) do
        {
          'admin'   => ['path/to/admin/spec'],
          'public'  => [],
          'reports' => ['path/to/reports/spec']
        } # end applications
      end # let
      let(:expected_results) do
        hsh = results.dup

        hsh['public']['RSpec'] =
          SleepingKingStudios::Tasks::Ci::RSpecResults.new({})
        hsh['Totals'] =
          {
            'RSpec' =>
              SleepingKingStudios::Tasks::Ci::RSpecResults.new(
                'duration'      => 2.5,
                'example_count' => 9,
                'failure_count' => 1,
                'pending_count' => 1
              ) # end RSpec results
          } # end totals

        hsh
      end # let

      include_examples 'should call an RSpec runner for each application'
    end # context
  end # describe
end # describe
