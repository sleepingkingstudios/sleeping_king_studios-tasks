# spec/sleeping_king_studios/tasks/ci/cucumber_runner_spec.rb

require 'sleeping_king_studios/tasks/ci/cucumber_runner'

RSpec.describe SleepingKingStudios::Tasks::Ci::CucumberRunner do
  let(:default_env) do
    { :ci => true, :bundle_gemfile => ENV['BUNDLE_GEMFILE'] }
  end # let
  let(:default_opts) { [] }
  let(:instance) do
    described_class.new :env => default_env, :options => default_opts
  end # let

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(0).arguments.
        and_keywords(:env, :options)
    end # it
  end # describe

  describe '#call' do
    let(:report) do
      {
        'scenario_count'     => 3,
        'failing_scenarios'  =>
          [
            {
              'location'    => 'features/example.feature:1',
              'description' => 'Scenario: failing scenario'
            } # end scenario
          ], # end failing scenarios
        'pending_scenarios'  =>
          [
            {
              'location'    => 'features/example.feature:1',
              'description' => 'Scenario: pending scenario'
            } # end scenario
          ], # end pending scenarios
        'step_count'         => 3,
        'failing_step_count' => 1,
        'pending_step_count' => 1,
        'duration'           => 0.3
      } # end report
    end # let
    let(:report_file)      { 'tmp/ci/cucumber.json' }
    let(:expected_files)   { [] }
    let(:expected_env)     { {} }
    let(:expected_options) { ['--format=json', "--out=#{report_file}"] }
    let(:expected_command) do
      opts = expected_files + default_opts + expected_options
      env  = default_env.merge expected_env
      env  = instance.send(:build_environment, :env => env)

      "#{env} bundle exec cucumber #{opts.join ' '}".strip
    end # let

    before(:example) do
      allow(instance).to receive(:stream_process)

      allow(File).to receive(:read).and_return('{}')
    end # before example

    it 'should define the method' do
      expect(instance).
        to respond_to(:call).
        with(0).arguments.
        and_keywords(:env, :files, :options, :report)
    end # it

    it 'should call a cucumber process' do
      expect(instance).to receive(:stream_process).with(expected_command)

      instance.call
    end # it

    it 'should load and parse the report file' do
      expect(File).
        to receive(:read).
        with(report_file).
        and_return({ 'report' => true }.to_json)

      expect(SleepingKingStudios::Tasks::Ci::CucumberParser).
        to receive(:parse).
        with('report' => true).
        and_return(report)

      expect(instance.call).to be == report
    end # it

    context 'when the report file is unparseable' do
      it 'should return empty results' do
        expect(File).
          to receive(:read).
          with(report_file).
          and_return('Greetings, programs!')

        expect(instance.call).to be == {}
      end # it
    end # context

    describe 'with :env => environment variables' do
      let(:env) { { :bundle_gemfile => 'path/to/Gemfile' } }
      let(:expected_env) do
        super().merge :bundle_gemfile => 'path/to/Gemfile'
      end # let

      it 'should call a cucumber process' do
        expect(instance).to receive(:stream_process).with(expected_command)

        instance.call :env => env
      end # it
    end # describe

    describe 'with :files => file list' do
      let(:expected_files) do
        ['features/foo', 'features/bar', 'features/wibble/wobble.feature']
      end # let

      it 'should call a cucumber process' do
        expect(instance).to receive(:stream_process).with(expected_command)

        instance.call :files => expected_files
      end # it
    end # describe

    describe 'with :options => custom options' do
      let(:options)          { ['--format=progress'] }
      let(:expected_options) { options + super() }

      it 'should call a cucumber process' do
        expect(instance).to receive(:stream_process).with(expected_command)

        instance.call :options => options
      end # it
    end # describe

    describe 'with :report => false' do
      let(:expected_options) { [] }

      it 'should call a cucumber process' do
        expect(instance).to receive(:stream_process).with(expected_command)

        instance.call :report => false
      end # it

      it 'should not load the report file' do
        expect(File).not_to receive(:read)

        expect(instance.call :report => false).to be == {}
      end # it
    end # describe

    describe 'with :report => file path' do
      let(:report_file) { 'tmp/cucumber.json' }

      it 'should load and parse the report file' do
        expect(File).
          to receive(:read).
          with(report_file).
          and_return({ 'report' => true }.to_json)

        expect(SleepingKingStudios::Tasks::Ci::CucumberParser).
          to receive(:parse).
          with('report' => true).
          and_return(report)

        expect(instance.call :report => report_file).to be == report
      end # it
    end # describe
  end # describe
end # describe
