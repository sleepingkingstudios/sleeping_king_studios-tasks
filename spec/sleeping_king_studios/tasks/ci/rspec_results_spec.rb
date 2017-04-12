# spec/sleeping_king_studios/tasks/ci/rspec_results_spec.rb

require 'sleeping_king_studios/tasks/ci/rspec_results'

RSpec.describe SleepingKingStudios::Tasks::Ci::RSpecResults do
  shared_context 'when the results are empty' do
    let(:results) { {} }
  end # shared_context

  shared_context 'when the results have no examples' do
    let(:results) do
      {
        'duration'      => 0.0,
        'example_count' => 0,
        'failure_count' => 0,
        'pending_count' => 0
      } # end results
    end # let
  end # shared_examples

  shared_context 'when the results are pending' do
    let(:results) { super().merge 'failure_count' => 0 }
  end # shared_context

  shared_context 'when the results are passing' do
    let(:results) { super().merge 'failure_count' => 0, 'pending_count' => 0 }
  end # shared_context

  let(:results) do
    {
      'duration'      => 1.0,
      'example_count' => 6,
      'failure_count' => 1,
      'pending_count' => 2
    } # end results
  end # let
  let(:instance) { described_class.new(results) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#==' do
    let(:other) do
      described_class.new(
        'duration'      => 1.0,
        'example_count' => 6,
        'failure_count' => 1,
        'pending_count' => 2
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
            'duration'      => 0.0,
            'example_count' => 0,
            'failure_count' => 0,
            'pending_count' => 0
          ) # end other
        end # let

        it { expect(instance).to be == other }
      end # describe
    end # wrap_context

    wrap_context 'when the results are passing' do
      it { expect(instance).not_to be == other }
    end # wrap_context
  end # describe

  describe '#duration' do
    include_examples 'should have reader',
      :duration,
      ->() { results['duration'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.duration).to be == 0.0 }
    end # wrap_context
  end # describe

  describe '#empty?' do
    include_examples 'should have predicate', :empty?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.empty?).to be true }
    end # wrap_context

    wrap_context 'when the results have no examples' do
      it { expect(instance.empty?).to be true }
    end # wrap_context
  end # describe

  describe '#example_count' do
    include_examples 'should have reader',
      :example_count,
      ->() { results['example_count'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.example_count).to be 0 }
    end # wrap_context
  end # describe

  describe '#failing?' do
    include_examples 'should have predicate', :failing?, true

    wrap_context 'when the results are empty' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results have no examples' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results are passing' do
      it { expect(instance.failing?).to be false }
    end # wrap_context
  end # describe

  describe '#failure_count' do
    include_examples 'should have reader',
      :failure_count,
      ->() { results['failure_count'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.failure_count).to be 0 }
    end # wrap_context
  end # describe

  describe '#pending?' do
    include_examples 'should have predicate', :pending?, true

    wrap_context 'when the results are empty' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results have no examples' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.pending?).to be true }
    end # wrap_context

    wrap_context 'when the results are passing' do
      it { expect(instance.pending?).to be false }
    end # wrap_context
  end # describe

  describe '#pending_count' do
    include_examples 'should have reader',
      :pending_count,
      ->() { results['pending_count'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.pending_count).to be 0 }
    end # wrap_context
  end # describe

  describe '#to_h' do
    it { expect(instance).to respond_to(:to_h).with(0).arguments }

    it { expect(instance.to_h).to be == results }

    wrap_context 'when the results are empty' do
      let(:expected) do
        {
          'duration'      => 0.0,
          'example_count' => 0,
          'failure_count' => 0,
          'pending_count' => 0
        } # end results
      end # let

      it { expect(instance.to_h).to be == expected }
    end # wrap_context

    wrap_context 'when the results have no examples' do
      it { expect(instance.to_h).to be == results }
    end # wrap_context
  end # describe

  describe '#to_s' do
    let(:expected) do
      str = "#{instance.example_count} examples"

      str << ", #{instance.failure_count} failures"

      if instance.pending?
        str << ", #{instance.pending_count} pending"
      end # if

      str << " in #{instance.duration.round(2)} seconds"
    end # let

    it { expect(instance).to respond_to(:to_s).with(0).arguments }

    it { expect(instance.to_s).to be == expected }

    wrap_context 'when the results are empty' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context

    wrap_context 'when the results have no examples' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context

    wrap_context 'when the results are passing' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context
  end # describe
end # describe
