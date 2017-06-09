# spec/sleeping_king_studios/tasks/apps/ci/simplecov_task_spec.rb

require 'simplecov'

require 'sleeping_king_studios/tasks/apps/ci/simplecov_task'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::SimpleCovTask do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::description' do
    let(:expected) { 'Aggregates the SimpleCov results for all applications.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'simplecov'
    end # it
  end # describe

  describe '::configure_simplecov!' do
    let(:config) do
      Class.new do
        def initialize
          @command_name = 'rspec'
          @formatter    = :default_formatter
        end # constructor

        attr_accessor :formatter

        def command_name *args
          args.empty? ? @command_name : @command_name = args.first
        end # method command_name
      end.new
    end # let

    it 'should define the class method' do
      expect(described_class).
        to respond_to(:configure_simplecov!).
        with(0).arguments
    end # it

    it 'should configure the formatter' do
      allow(::SimpleCov).to receive(:configure) do |&block|
        config.instance_exec(&block)
      end # allow

      described_class.configure_simplecov!

      formatter = config.formatter.new
      expect(formatter.formatters).
        to contain_exactly(
          :default_formatter,
          SimpleCov::Formatter::JSONFormatter
        ) # end contain_exactly
    end # it

    context 'when ENV["APP_NAME"] is set' do
      let(:name) { 'tps_reports' }

      around(:example) do |example|
        begin
          prior           = ENV['APP_NAME']
          ENV['APP_NAME'] = name

          example.call
        ensure
          ENV['APP_NAME'] = prior
        end # begin-ensure
      end # around example

      it 'should configure the formatter' do
        allow(::SimpleCov).to receive(:configure) do |&block|
          config.instance_exec(&block)
        end # allow

        described_class.configure_simplecov!

        expect(config.command_name).to be == "rspec:#{name}"

        formatter = config.formatter.new
        expect(formatter.formatters).
          to contain_exactly(
            :default_formatter,
            SimpleCov::Formatter::JSONFormatter
          ) # end contain_exactly
      end # it
    end # context
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

    context 'when the report fails to load' do
      let(:raw) { 'not JSON, no sirree' }

      it 'should return an empty data hash' do
        results = nil

        expect { results = instance.send :load_report, :report => report }.
          not_to raise_error

        expect(results).to be == {}
      end # it
    end # context
  end # describe
end # describe
