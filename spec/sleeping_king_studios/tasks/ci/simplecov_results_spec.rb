# spec/sleeping_king_studios/tasks/ci/simplecov_results_spec.rb

require 'sleeping_king_studios/tasks/ci/simplecov_results'

RSpec.describe SleepingKingStudios::Tasks::Ci::SimpleCovResults do
  shared_examples 'when the results are empty' do
    let(:results) do
      double(
        'results',
        :covered_percent => 100.0,
        :covered_lines   => 0,
        :missed_lines    => 0,
        :total_lines     => 0
      ) # end results
    end # let
  end # shared_examples

  shared_examples 'when the results are failing' do
    let(:results) do
      double(
        'results',
        :covered_percent => 85.0,
        :covered_lines   => 85,
        :missed_lines    => 15,
        :total_lines     => 100
      ) # end results
    end # let
  end # shared_examples

  shared_examples 'when the results are exactly failing' do
    let(:results) do
      double(
        'results',
        :covered_percent => 90.0,
        :covered_lines   => 90,
        :missed_lines    => 10,
        :total_lines     => 100
      ) # end results
    end # let
  end # shared_examples

  shared_examples 'when the results are pending' do
    let(:results) do
      double(
        'results',
        :covered_percent => 92.0,
        :covered_lines   => 92,
        :missed_lines    => 8,
        :total_lines     => 100
      ) # end results
    end # let
  end # shared_examples

  shared_examples 'when the results are exactly pending' do
    let(:results) do
      double(
        'results',
        :covered_percent => 95.0,
        :covered_lines   => 95,
        :missed_lines    => 5,
        :total_lines     => 100
      ) # end results
    end # let
  end # shared_examples

  let(:results) do
    double(
      'results',
      :covered_percent => 97.0,
      :covered_lines   => 97,
      :missed_lines    => 3,
      :total_lines     => 100
    ) # end results
  end # let
  let(:instance) { described_class.new results }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#covered_lines' do
    include_examples 'should have reader',
      :covered_lines,
      ->() { results.covered_lines }
  end # describe

  describe '#covered_percent' do
    include_examples 'should have reader',
      :covered_percent,
      ->() { results.covered_percent }
  end # describe

  describe '#empty?' do
    include_examples 'should have predicate', :empty?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.empty?).to be true }
    end # wrap_context
  end # describe

  describe '#failing?' do
    include_examples 'should have predicate', :failing?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance.failing?).to be true }
    end # wrap_context

    wrap_context 'when the results are exactly failing' do
      it { expect(instance.failing?).to be true }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results are exactly pending' do
      it { expect(instance.failing?).to be false }
    end # wrap_context
  end # describe

  describe '#failing_percent' do
    include_examples 'should have reader', :failing_percent, 90.0
  end # describe

  describe '#missed_lines' do
    include_examples 'should have reader',
      :missed_lines,
      ->() { results.missed_lines }
  end # describe

  describe '#pending?' do
    include_examples 'should have predicate', :pending?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results are exactly failing' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.pending?).to be true }
    end # wrap_context

    wrap_context 'when the results are exactly pending' do
      it { expect(instance.pending?).to be true }
    end # wrap_context
  end # describe

  describe '#pending_percent' do
    include_examples 'should have reader', :pending_percent, 95.0
  end # describe

  describe '#to_s' do
    let(:expected) do
      str = "#{instance.covered_percent.round(2)}% coverage"

      str << ", #{instance.missed_lines} missed lines"

      str << ", #{instance.total_lines} total lines"
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
  end # describe

  describe '#total_lines' do
    include_examples 'should have reader',
      :total_lines,
      ->() { results.total_lines }
  end # describe
end # describe
