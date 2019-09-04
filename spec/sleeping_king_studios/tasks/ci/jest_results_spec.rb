# frozen_string_literal: true

require 'sleeping_king_studios/tasks/ci/jest_results'

RSpec.describe SleepingKingStudios::Tasks::Ci::JestResults do
  shared_context 'when the results are empty' do
    let(:results) { {} }
  end

  shared_context 'when the results have no tests' do
    let(:results) do
      start_time = Time.new(1982, 7, 9).to_i

      {
        'numTotalTests'   => 0,
        'numFailedTests'  => 0,
        'numPendingTests' => 0,
        'startTime'       => start_time,
        'testResults'     => [
          { 'endTime' => start_time }
        ]
      }
    end
  end

  shared_context 'when the results are pending' do
    let(:results) { super().merge 'numFailedTests' => 0 }
  end

  shared_context 'when the results are passing' do
    let(:results) do
      super().merge 'numFailedTests' => 0, 'numPendingTests' => 0
    end
  end

  let(:start_time) { Time.new(1982, 7, 9).to_i }
  let(:end_time)   { start_time + 1234 }
  let(:results) do
    {
      'numTotalTests'   => 6,
      'numFailedTests'  => 1,
      'numPendingTests' => 2,
      'startTime'       => start_time,
      'testResults'     => [
        { 'endTime' => end_time }
      ]
    }
  end
  let(:instance) { described_class.new(results) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#==' do
    let(:other) do
      described_class.new(
        'numTotalTests'   => 6,
        'numFailedTests'  => 1,
        'numPendingTests' => 2,
        'startTime'       => start_time,
        'testResults'     => [
          { 'endTime' => end_time }
        ]
      )
    end

    it { expect(instance).to be == other }

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(instance).not_to be == nil }
      # rubocop:enable Style/NilComparison
    end # describe

    describe 'with an empty hash' do
      it { expect(instance).not_to be == {} }
    end

    describe 'with a matching hash' do
      it { expect(instance).to be == results }
    end

    wrap_context 'when the results are empty' do
      it { expect(instance).not_to be == other }

      describe 'with an empty hash' do
        it { expect(instance).to be == {} }
      end

      describe 'with an empty results object' do
        let(:other) { described_class.new({}) }

        it { expect(instance).to be == other }
      end

      describe 'with a results object with no examples' do
        let(:other) do
          start_time = Time.new(1982, 7, 9).to_i

          described_class.new(
            'numTotalTests'   => 0,
            'numFailedTests'  => 0,
            'numPendingTests' => 0,
            'startTime'       => start_time,
            'testResults'     => [
              { 'endTime' => start_time }
            ]
          )
        end

        it { expect(instance).to be == other }
      end
    end

    wrap_context 'when the results are passing' do
      it { expect(instance).not_to be == other }
    end
  end

  describe '#duration' do
    let(:expected) { (end_time - start_time).to_f / 1000 }

    include_examples 'should have reader',
      :duration,
      ->() { expected }

    wrap_context 'when the results are empty' do
      it { expect(instance.duration).to be == 0.0 }
    end

    context 'when there are multiple testResults objects' do
      let(:results) do
        super().tap do |hsh|
          hsh['testResults'] <<
            { 'endTime' => end_time - 250 } <<
            { 'endTime' => end_time - 500 } <<
            { 'endTime' => end_time - 750 }
        end
      end

      it { expect(instance.duration).to be == expected }
    end
  end

  describe '#empty?' do
    include_examples 'should have predicate', :empty?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.empty?).to be true }
    end

    wrap_context 'when the results have no tests' do
      it { expect(instance.empty?).to be true }
    end
  end

  describe '#failing?' do
    include_examples 'should have predicate', :failing?, true

    wrap_context 'when the results are empty' do
      it { expect(instance.failing?).to be false }
    end

    wrap_context 'when the results have no tests' do
      it { expect(instance.failing?).to be false }
    end

    wrap_context 'when the results are passing' do
      it { expect(instance.failing?).to be false }
    end
  end

  describe '#failure_count' do
    include_examples 'should have reader',
      :failure_count,
      ->() { results['numFailedTests'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.failure_count).to be 0 }
    end
  end

  describe '#pending?' do
    include_examples 'should have predicate', :pending?, true

    wrap_context 'when the results are empty' do
      it { expect(instance.pending?).to be false }
    end

    wrap_context 'when the results have no tests' do
      it { expect(instance.pending?).to be false }
    end

    wrap_context 'when the results are pending' do
      it { expect(instance.pending?).to be true }
    end

    wrap_context 'when the results are passing' do
      it { expect(instance.pending?).to be false }
    end
  end

  describe '#pending_count' do
    include_examples 'should have reader',
      :pending_count,
      ->() { results['numPendingTests'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.pending_count).to be 0 }
    end
  end

  describe '#test_count' do
    include_examples 'should have reader',
      :test_count,
      ->() { results['numTotalTests'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.test_count).to be 0 }
    end
  end

  describe '#to_h' do
    let(:expected) do
      {
        'duration'      => instance.duration,
        'failure_count' => instance.failure_count,
        'pending_count' => instance.pending_count,
        'test_count'    => instance.test_count
      }
    end

    it { expect(instance).to respond_to(:to_h).with(0).arguments }

    it { expect(instance.to_h).to be == expected }

    wrap_context 'when the results are empty' do
      it { expect(instance.to_h).to be == expected }
    end

    wrap_context 'when the results have no tests' do
      it { expect(instance.to_h).to be == expected }
    end
  end

  describe '#to_s' do
    let(:expected) do
      str = +"#{instance.test_count} tests"

      str << ", #{instance.failure_count} failure"
      str << 's' if instance.failure_count != 1

      str << ", #{instance.pending_count} pending" if instance.pending?

      str << " in #{instance.duration.round(2)} seconds"
    end

    it { expect(instance).to respond_to(:to_s).with(0).arguments }

    it { expect(instance.to_s).to be == expected }

    wrap_context 'when the results are empty' do
      it { expect(instance.to_s).to be == expected }
    end

    wrap_context 'when the results have no tests' do
      it { expect(instance.to_s).to be == expected }
    end

    wrap_context 'when the results are pending' do
      it { expect(instance.to_s).to be == expected }
    end

    wrap_context 'when the results are passing' do
      it { expect(instance.to_s).to be == expected }
    end
  end
end
