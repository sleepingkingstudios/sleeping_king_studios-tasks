# spec/sleeping_king_studios/tasks/ci/rspec_each_results_spec.rb

require 'sleeping_king_studios/tasks/ci/rspec_each_results'

RSpec.describe SleepingKingStudios::Tasks::Ci::RSpecEachResults do
  shared_context 'when the results are empty' do
    let(:results) { {} }
  end # shared_context

  shared_context 'when the results are failing' do
    let(:results) do
      super().merge 'failing_files' =>
        ['path/to/first', 'path/to/second', 'path/to/third']
    end # let
  end # shared_context

  shared_context 'when the results are pending' do
    let(:results) do
      super().merge 'pending_files' =>
        ['path/to/first', 'path/to/second', 'path/to/third']
    end # let
  end # shared_context

  shared_context 'when the results have errors' do
    let(:results) do
      super().merge 'errored_files' =>
        ['path/to/first', 'path/to/second', 'path/to/third']
    end # let
  end # shared_context

  let(:results) do
    {
      'failing_files' => [],
      'pending_files' => [],
      'errored_files' => [],
      'file_count'    => 6,
      'duration'      => 10.0
    } # end results
  end # let
  let(:instance) { described_class.new(results) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#==' do
    let(:other) do
      described_class.new(
        'failing_files' => [],
        'pending_files' => [],
        'errored_files' => [],
        'file_count'    => 6,
        'duration'      => 10.0
      ) # end other
    end # let

    it { expect(instance).to be == other }

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(instance).not_to be == nil }
      # rubocop:enable Style/NilComparison
    end # describe

    describe 'with an empty hash' do
      it { expect(instance).not_to be == {} }
    end # describe

    describe 'with a matching hash' do
      it { expect(instance).to be == results }
    end # describe

    wrap_context 'when the results are empty' do
      it { expect(instance).not_to be == other }

      describe 'with an empty hash' do
        it { expect(instance).to be == {} }
      end # describe

      describe 'with an empty results object' do
        let(:other) { described_class.new({}) }

        it { expect(instance).to be == other }
      end # describe

      describe 'with a results object with no examples' do
        let(:other) do
          described_class.new(
            'failing_files' => [],
            'pending_files' => [],
            'file_count'    => 0,
            'duration'      => 0.0
          ) # end other
        end # let

        it { expect(instance).to be == other }
      end # describe
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance).not_to be == other }
    end # wrap_context
  end # describe

  describe '#duration' do
    include_examples 'should have reader',
      :duration,
      ->() { be == results['duration'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.duration).to be == 0.0 }
    end # wrap_context
  end # describe

  describe '#empty?' do
    include_examples 'should have predicate', :empty?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.empty?).to be true }
    end # wrap_context
  end # describe

  describe '#errored?' do
    include_examples 'should have predicate', :errored?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.errored?).to be false }
    end # wrap_context

    wrap_context 'when the results have errors' do
      it { expect(instance.errored?).to be true }
    end # wrap_context
  end # describe

  describe '#errored_count' do
    include_examples 'should have reader',
      :failure_count,
      ->() { be == results['errored_files'].count }

    wrap_context 'when the results are empty' do
      it { expect(instance.errored_count).to be == 0 }
    end # wrap_context

    wrap_context 'when the results have errors' do
      it 'should define the reader' do
        expect(instance.errored_count).to be == results['errored_files'].count
      end # it
    end # wrap_context
  end # describe

  describe '#errored_files' do
    include_examples 'should have reader',
      :errored_files,
      ->() { results['errored_files'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.errored_files).to be == [] }
    end # wrap_context

    wrap_context 'when the results have errors' do
      it { expect(instance.errored_files).to be == results['errored_files'] }
    end # wraP-context
  end # describe

  describe '#failing?' do
    include_examples 'should have predicate', :failing?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance.failing?).to be true }
    end # wrap_context
  end # describe

  describe '#failing_files' do
    include_examples 'should have reader',
      :failing_files,
      ->() { be == results['failing_files'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.failing_files).to be == [] }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance.failing_files).to be == results['failing_files'] }
    end # wrap_context
  end # describe

  describe '#failure_count' do
    include_examples 'should have reader',
      :failure_count,
      ->() { be == results['failing_files'].count }

    wrap_context 'when the results are empty' do
      it { expect(instance.failure_count).to be == 0 }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it 'should define the reader' do
        expect(instance.failure_count).to be == results['failing_files'].count
      end # it
    end # wrap_context
  end # describe

  describe '#file_count' do
    include_examples 'should have reader',
      :file_count,
      ->() { be == results['file_count'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.file_count).to be == 0 }
    end # wrap_context
  end # describe

  describe '#pending?' do
    include_examples 'should have predicate', :pending?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.pending?).to be true }
    end # wrap_context
  end # describe

  describe '#pending_count' do
    include_examples 'should have reader',
      :pending_count,
      ->() { be == results['pending_files'].count }

    wrap_context 'when the results are empty' do
      it { expect(instance.pending_count).to be == 0 }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it 'should define the reader' do
        expect(instance.pending_count).to be == results['pending_files'].count
      end # it
    end # wrap_context
  end # describe

  describe '#pending_files' do
    include_examples 'should have reader',
      :pending_files,
      ->() { be == results['pending_files'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.pending_files).to be == [] }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.pending_files).to be == results['pending_files'] }
    end # wrap_context
  end # describe

  describe '#to_h' do
    it { expect(instance).to respond_to(:to_h).with(0).arguments }

    it { expect(instance.to_h).to be == results }

    wrap_context 'when the results are empty' do
      let(:expected) do
        {
          'failing_files' => [],
          'pending_files' => [],
          'errored_files' => [],
          'file_count'    => 0,
          'duration'      => 0.0
        } # end results
      end # let

      it { expect(instance.to_h).to be == expected }
    end # wrap_context
  end # describe

  describe '#to_s' do
    let(:expected) do
      str = "#{instance.file_count} files"

      str << ", #{instance.failure_count} failures"

      if instance.pending?
        str << ", #{instance.pending_count} pending"
      end # if

      if instance.errored?
        str << ", #{instance.errored_count} errored"
      end # if

      str << " in #{instance.duration.round(2)} seconds"
    end # let

    it { expect(instance).to respond_to(:to_s).with(0).arguments }

    it { expect(instance.to_s).to be == expected }

    wrap_context 'when the results are empty' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context

    wrap_context 'when the results have errors' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context
  end # describe
end # describe
