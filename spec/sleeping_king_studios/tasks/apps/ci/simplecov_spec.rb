# spec/sleeping_king_studios/tasks/apps/ci/simplecov_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/simplecov'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::SimpleCov do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    let(:data) do
      {
        'metrics' => {
          'total_lines'     => 100,
          'covered_lines'   => 85,
          'covered_percent' => 85.0
        } # end metrics
      } # end data
    end # let
    let(:report) { File.join('coverage', 'coverage.json') }

    it { expect(instance).to respond_to(:call).with(0..1).arguments }

    it 'should load the coverage data and convert it to a results object' do
      expect(instance).
        to receive(:load_report).
        with(:report => report).
        and_return(data['metrics'])

      results = instance.call

      expect(results).to be_a SleepingKingStudios::Tasks::Ci::SimpleCovResults

      expect(results.total_lines).to be == 100
      expect(results.missed_lines).to be == 15
      expect(results.covered_lines).to be == 85
      expect(results.covered_percent).to be == 85.0
    end # it
  end # describe

  describe '#load_report' do
    let(:data) do
      {
        'metrics' => {
          'total_lines'     => 100,
          'covered_lines'   => 85,
          'covered_percent' => 85.0
        } # end metrics
      } # end data
    end # let
    let(:raw)    { JSON.dump data }
    let(:report) { 'path/to/file' }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:load_report)

      expect(instance).
        to respond_to(:load_report, true).
        with(0).arguments.
        and_keywords(:report)
    end # it

    it 'should load the file' do
      expect(File).to receive(:read).with(report).and_return(raw)

      results = instance.send :load_report, :report => report

      expect(results).to be == data['metrics']
    end # it
  end # describe
end # describe
