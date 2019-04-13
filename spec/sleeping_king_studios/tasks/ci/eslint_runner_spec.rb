# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci/eslint_runner'

RSpec.describe SleepingKingStudios::Tasks::Ci::EslintRunner do
  let(:default_env) do
    { :ci => true, :bundle_gemfile => ENV['BUNDLE_GEMFILE'] }
  end
  let(:default_opts) { ['--color'] }
  let(:instance) do
    described_class.new :env => default_env, :options => default_opts
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(0).arguments.
        and_keywords(:env, :options)
    end
  end

  describe '#call' do
    let(:directory) { Dir.getwd }
    let(:report) do
      [
        {
          'filePath'     => "#{directory}/passing_file.js",
          'errorCount'   => 0,
          'warningCount' => 0
        },
        {
          'filePath'     => "#{directory}/file_with_errors.js",
          'errorCount'   => 3,
          'warningCount' => 0
        },
        {
          'filePath'     => "#{directory}/file_with_warnings.js",
          'errorCount'   => 0,
          'warningCount' => 6
        },
        {
          'filePath'     => "#{directory}/file_with_errors_and_warnings.js",
          'errorCount'   => 2,
          'warningCount' => 4
        }
      ]
    end
    let(:report_file)      { 'tmp/ci/eslint.json' }
    let(:expected_files)   { ['"**/*.js"'] }
    let(:expected_env)     { {} }
    let(:expected_options) { ['--format=json', "--output-file=#{report_file}"] }
    let(:expected_command) do
      opts = expected_files + default_opts + expected_options
      env  = default_env.merge expected_env
      env  = instance.send(:build_environment, :env => env)

      "#{env} yarn eslint #{opts.join ' '}".strip
    end

    before(:example) do
      allow(instance).to receive(:stream_process)

      allow(File).to receive(:read).and_return('[]')
    end

    it 'should define the method' do
      expect(instance).
        to respond_to(:call).
        with(0).arguments.
        and_keywords(:env, :files, :options, :report)
    end

    it 'should call an eslint process' do
      expect(instance).to receive(:stream_process).with(expected_command)

      instance.call
    end

    it 'should load and parse the report file' do
      expect(File).
        to receive(:read).
        with(report_file).
        and_return(JSON.dump report)

      expect(instance.call).to be == report
    end

    context 'when the report file is unparseable' do
      it 'should return empty results' do
        expect(File).
          to receive(:read).
          with(report_file).
          and_return('Greetings, programs!')

        expect(instance.call).to be == []
      end
    end

    describe 'with :env => environment variables' do
      let(:env) { { :node_env => 'test' } }
      let(:expected_env) do
        super().merge :node_env => 'test'
      end

      it 'should call an eslint process' do
        expect(instance).to receive(:stream_process).with(expected_command)

        instance.call :env => env
      end
    end

    describe 'with :files => file list' do
      let(:expected_files) do
        ['src/foo', 'src/bar', 'src/wibble/wobble.test.js']
      end

      it 'should call an eslint process' do
        expect(instance).to receive(:stream_process).with(expected_command)

        instance.call :files => expected_files
      end
    end

    describe 'with :options => custom options' do
      let(:options)          { ['--format=stylish'] }
      let(:expected_options) { options + super() }

      it 'should call an eslint process' do
        expect(instance).to receive(:stream_process).with(expected_command)

        instance.call :options => options
      end
    end

    describe 'with :report => false' do
      let(:expected_options) { [] }

      it 'should call an eslint process' do
        expect(instance).to receive(:stream_process).with(expected_command)

        instance.call :report => false
      end

      it 'should not load the report file' do
        expect(File).not_to receive(:read)

        expect(instance.call :report => false).to be == []
      end
    end

    describe 'with :report => file path' do
      let(:report_file) { 'tmp/eslint.json' }

      it 'should load and parse the report file' do
        expect(File).
          to receive(:read).
          with(report_file).
          and_return(JSON.dump report)

        expect(instance.call :report => report_file).to be == report
      end
    end
  end
end
