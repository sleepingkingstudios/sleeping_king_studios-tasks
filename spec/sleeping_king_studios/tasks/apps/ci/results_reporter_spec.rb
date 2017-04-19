# spec/sleeping_king_studios/tasks/apps/ci/results_reporter_spec.rb

require 'sleeping_king_studios/tasks/apps/applications_task'
require 'sleeping_king_studios/tasks/apps/ci/results_reporter'
require 'sleeping_king_studios/tasks/ci/rspec_each_results'
require 'sleeping_king_studios/tasks/ci/rspec_results'
require 'sleeping_king_studios/tasks/ci/rubocop_results'
require 'sleeping_king_studios/tasks/ci/simplecov_results'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::ResultsReporter do
  let(:context)  { SleepingKingStudios::Tasks::Apps::ApplicationsTask.new({}) }
  let(:instance) { described_class.new(context) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    let(:applications) do
      {
        'admin'   => { 'name' => 'Admin' },
        'public'  => { 'name' => 'Public' },
        'reports' => { 'name' => 'Reports' }
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
              ), # end RSpec results
            'RuboCop' =>
              SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
                'inspected_file_count' => 5,
                'offense_count'        => 2
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
              ), # end RSpec results
            'RSpec (Each)' =>
              SleepingKingStudios::Tasks::Ci::RSpecEachResults.new(
                'failing_files' => [],
                'pending_files' => [],
                'file_count'    => 10,
                'duration'      => 10.0
              ) # end RSpecEach results
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
            'SimpleCov' =>
              SleepingKingStudios::Tasks::Ci::SimpleCovResults.new(
                double(
                  'results',
                  :covered_percent => 100.0,
                  :covered_lines   => 50,
                  :missed_lines    => 0,
                  :total_lines     => 50
                ) # end results
              ) # end RSpec results
          } # end totals
      } # end results
    end # let

    before(:example) do
      allow(context).to receive(:applications).and_return(applications)
    end # before example

    def capture_stdout
      buffer  = StringIO.new
      prior   = $stdout
      $stdout = buffer

      yield

      buffer.string
    ensure
      $stdout = prior
    end # method capture_stdout

    def expect_to_have_matching_line str
      expect(str.each_line).to satisfy { |enum|
        enum.any? { |line| yield line }
      } # end satisfy
    end # method expect_to_have_matching_line

    it { expect(instance).to respond_to(:call).with(1).argument }

    it 'should report the results for each application' do
      captured = capture_stdout { instance.call(results) }

      results.each do |key, hsh|
        app_name = applications.fetch(key, {}).fetch('name', key)

        expect_to_have_matching_line(captured) do |line|
          line.include? "#{app_name}:"
        end # expect

        hsh.each do |badge, obj|
          expect_to_have_matching_line(captured) do |line|
            line.include?(badge) && line.include?(obj.to_s)
          end # expect
        end # each
      end # each
    end # it
  end # describe
end # describe
