# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci/eslint_task'

RSpec.describe SleepingKingStudios::Tasks::Ci::EslintTask do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the ESLint linter.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end
  end

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'eslint'
    end
  end

  describe '#call' do
    shared_examples 'should call an ESLint runner' do
      it 'should call an ESLint runner' do
        allow(SleepingKingStudios::Tasks::Ci::EslintRunner).
          to receive(:new).
          with(:options => expected_options).
          and_return(runner)

        expect(runner).
          to receive(:call).
          with(:files => expected_files).
          and_return(expected)

        results = instance.call(*expected_files)

        expect(results).to be_a expected_class
        expect(results).to be == expected
      end
    end

    let(:expected_files)   { [] }
    let(:expected_options) { ['--color'] }
    let(:expected_class)   { SleepingKingStudios::Tasks::Ci::EslintResults }
    let(:directory)        { Dir.getwd }
    let(:expected) do
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
    let(:runner) do
      SleepingKingStudios::Tasks::Ci::EslintRunner.
        new(:options => expected_options)
    end

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call an ESLint runner'

    describe 'with files' do
      let(:expected_files) do
        ['src/foo', 'src/bar', 'src/wibble/wobble.test.js']
      end

      include_examples 'should call an ESLint runner'
    end
  end
end
