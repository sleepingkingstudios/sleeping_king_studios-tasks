# spec/sleeping_king_studios/tasks/apps/ci/rubocop_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/rubocop'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::RuboCop do
  let(:options)  { { 'quiet' => true } }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the RuboCop linter for each application.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'rubocop'
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should call a RuboCop runner for each application' do
      describe 'should call an RuboCop runner for each application' do
        before(:example) do
          allow(instance).to receive(:applications).and_return(applications)

          allow(SleepingKingStudios::Tasks::Ci::RuboCopRunner).
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
              and_return(results[name]['RuboCop'].to_h)
          end # each

          if options.fetch('report', true)
            expect(reporter).to receive(:call).with(expected_results)
          else
            expect(reporter).not_to receive(:call)
          end # if

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
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 5,
                'offense_count'        => 3
              ) # end RuboCop results
          }, # end admin
        'public' =>
          {
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 10,
                'offense_count'        => 1
              ) # end RuboCop results
          }, # end public
        'reports' =>
          {
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 15,
                'offense_count'        => 0
              ) # end RuboCop results
          }, # end reports
        'Totals' =>
          {
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 30,
                'offense_count'        => 4
              ) # end RuboCop results
          } # end totals
      } # end results
    end # let
    let(:only) { [] }
    let(:expected_applications) { applications }
    let(:expected_results)      { results }
    let(:expected_options)      { ['--color'] }
    let(:reporter) do
      SleepingKingStudios::Tasks::Apps::Ci::ResultsReporter.new(instance)
    end # let
    let(:runner) do
      SleepingKingStudios::Tasks::Ci::RuboCopRunner.
        new(:options => expected_options)
    end # let

    before(:example) do
      allow(instance).to receive(:applications).and_return(applications)
    end # before example

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call a RuboCop runner for each application'

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

      include_examples 'should call a RuboCop runner for each application'
    end # describe

    describe 'with :report => false' do
      let(:options) { super().merge 'report' => false }

      include_examples 'should call a RuboCop runner for each application'
    end # describe

    context 'when an application disables the rspec step' do
      let(:applications) do
        hsh = super()

        (hsh['public']['ci'] = {})['rubocop'] = false

        hsh
      end # let
      let(:expected_applications) do
        applications.reject { |key, _| key == 'public' }
      end # let
      let(:expected_results) do
        hsh = results.dup

        hsh.delete('public')

        hsh['Totals'] =
          {
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 20,
                'offense_count'        => 3
              ) # end RSpec results
          } # end totals

        hsh
      end # let

      include_examples 'should call a RuboCop runner for each application'
    end # context
  end # describe
end # describe
