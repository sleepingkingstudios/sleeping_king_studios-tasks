# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci/eslint_results'

RSpec.describe SleepingKingStudios::Tasks::Ci::EslintResults do
  shared_context 'when the results are empty' do
    let(:results) { [] }
  end

  shared_context 'when the results have no errors or warnings' do
    let(:results) do
      [
        {
          'filePath'     => "#{directory}/passing_file",
          'errorCount'   => 0,
          'warningCount' => 0
        }
      ]
    end
  end

  shared_context 'when the results have only errors' do
    let(:results) do
      [
        {
          'filePath'     => "#{directory}/passing_file",
          'errorCount'   => 0,
          'warningCount' => 0
        },
        {
          'filePath'     => "#{directory}/file_with_errors.js",
          'errorCount'   => 3,
          'warningCount' => 0
        }
      ]
    end
  end

  let(:directory) { Dir.getwd }
  let(:results) do
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
  let(:instance) { described_class.new results }

  describe '#==' do
    let(:other) do
      described_class.new(
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
      )
    end

    it { expect(instance).to be == other }

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(instance).not_to be == nil }
      # rubocop:enable Style/NilComparison
    end

    describe 'with an empty array' do
      it { expect(instance).not_to be == [] }
    end

    describe 'with a matching array' do
      it { expect(instance).to be == results }
    end

    wrap_context 'when the results are empty' do
      it { expect(instance).not_to be == other }

      describe 'with an empty array' do
        it { expect(instance).to be == [] }
      end

      describe 'with an empty results object' do
        let(:other) { described_class.new([]) }

        it { expect(instance).to be == other }
      end
    end

    wrap_context 'when the results have no errors or warnings' do
      it { expect(instance).not_to be == other }
    end
  end

  describe '#empty?' do
    it { expect(instance).to have_predicate(:empty?).with_value(false) }

    wrap_context 'when the results are empty' do
      it { expect(instance.empty?).to be true }
    end
  end

  describe '#error_count' do
    include_examples 'should have reader', :error_count, 5

    wrap_context 'when the results are empty' do
      it { expect(instance.error_count).to be 0 }
    end

    wrap_context 'when the results have no errors or warnings' do
      it { expect(instance.error_count).to be 0 }
    end

    wrap_context 'when the results have only errors' do
      it { expect(instance.error_count).to be 3 }
    end
  end

  describe '#failing?' do
    it { expect(instance).to have_predicate(:failing?).with_value(true) }

    wrap_context 'when the results are empty' do
      it { expect(instance.failing?).to be false }
    end

    wrap_context 'when the results have no errors or warnings' do
      it { expect(instance.failing?).to be false }
    end

    wrap_context 'when the results have only errors' do
      it { expect(instance.failing?).to be true }
    end
  end

  describe '#inspected_file_count' do
    include_examples 'should have reader', :inspected_file_count, 4

    wrap_context 'when the results are empty' do
      it { expect(instance.inspected_file_count).to be 0 }
    end
  end

  describe '#pending?' do
    it { expect(instance).to have_predicate(:pending?).with_value(false) }

    wrap_context 'when the results are empty' do
      it { expect(instance.pending?).to be false }
    end

    wrap_context 'when the results have no errors or warnings' do
      it { expect(instance.pending?).to be false }
    end

    wrap_context 'when the results have only errors' do
      it { expect(instance.pending?).to be false }
    end
  end

  describe '#to_h' do
    let(:expected) do
      {
        'inspected_file_count' => 4,
        'error_count'          => 5,
        'warning_count'        => 10
      }
    end

    it { expect(instance.to_h).to be == expected }

    wrap_context 'when the results are empty' do
      let(:expected) do
        {
          'inspected_file_count' => 0,
          'error_count'          => 0,
          'warning_count'        => 0
        }
      end

      it { expect(instance.to_h).to be == expected }
    end

    wrap_context 'when the results have no errors or warnings' do
      let(:expected) do
        {
          'inspected_file_count' => 1,
          'error_count'          => 0,
          'warning_count'        => 0
        }
      end

      it { expect(instance.to_h).to be == expected }
    end

    wrap_context 'when the results have only errors' do
      let(:expected) do
        {
          'inspected_file_count' => 2,
          'error_count'          => 3,
          'warning_count'        => 0
        }
      end

      it { expect(instance.to_h).to be == expected }
    end
  end

  describe '#to_s' do
    let(:expected) do
      <<~OUTPUT.strip
        4 files inspected, 5 errors, 10 warnings

            file_with_errors.js: 3 errors, 0 warnings
            file_with_warnings.js: 0 errors, 6 warnings
            file_with_errors_and_warnings.js: 2 errors, 4 warnings
      OUTPUT
    end

    it { expect(instance.to_s).to be == expected }

    wrap_context 'when the results are empty' do
      let(:expected) { '0 files inspected, 0 errors, 0 warnings' }

      it { expect(instance.to_s).to be == expected }
    end

    wrap_context 'when the results have no errors or warnings' do
      let(:expected) { '1 file inspected, 0 errors, 0 warnings' }

      it { expect(instance.to_s).to be == expected }
    end

    wrap_context 'when the results have only errors' do
      let(:expected) do
        <<~OUTPUT.strip
          2 files inspected, 3 errors, 0 warnings

              file_with_errors.js: 3 errors, 0 warnings
        OUTPUT
      end

      it { expect(instance.to_s).to be == expected }
    end
  end

  describe '#warning_count' do
    include_examples 'should have reader', :warning_count, 10

    wrap_context 'when the results are empty' do
      it { expect(instance.warning_count).to be 0 }
    end

    wrap_context 'when the results have no errors or warnings' do
      it { expect(instance.warning_count).to be 0 }
    end

    wrap_context 'when the results have only errors' do
      it { expect(instance.warning_count).to be 0 }
    end
  end
end
