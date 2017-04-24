# spec/sleeping_king_studios/tasks/ci/rubocop_results_spec.rb

require 'sleeping_king_studios/tasks/ci/rubocop_results'

RSpec.describe SleepingKingStudios::Tasks::Ci::RuboCopResults do
  shared_context 'when the results are empty' do
    let(:results) { {} }
  end # shared_context

  shared_context 'when the results have no examples' do
    let(:results) do
      {
        'inspected_file_count' => 0,
        'offense_count'        => 0
      } # end results
    end # let
  end # shared_context

  shared_context 'when the results have no offenses' do
    let(:results) do
      {
        'inspected_file_count' => 10,
        'offense_count'        => 0
      } # end results
    end # let
  end # shared_context

  let(:results) do
    {
      'inspected_file_count' => 10,
      'offense_count'        => 3
    } # end results
  end # let
  let(:instance) { described_class.new results }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#==' do
    let(:other) do
      described_class.new(
        'inspected_file_count' => 10,
        'offense_count'        => 3
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
            'inspected_file_count' => 0,
            'offense_count'        => 0
          ) # end other
        end # let

        it { expect(instance).to be == other }
      end # describe
    end # wrap_context

    wrap_context 'when the results have no offenses' do
      it { expect(instance).not_to be == other }
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

  describe '#failing?' do
    include_examples 'should have predicate', :failing?, true

    wrap_context 'when the results are empty' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results have no examples' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results have no offenses' do
      it { expect(instance.failing?).to be false }
    end # wrap_context
  end # describe

  describe '#inspected_file_count' do
    include_examples 'should have reader',
      :inspected_file_count,
      ->() { results['inspected_file_count'] }

    wrap_examples 'when the results are empty' do
      it { expect(instance.inspected_file_count).to be 0 }
    end # wrap_examples
  end # describe

  describe '#merge' do
    let(:other) do
      described_class.new(
        'inspected_file_count' => 20,
        'offense_count'        => 5
      ) # end results
    end # let

    it { expect(instance).to respond_to(:merge).with(1).argument }

    it 'should not change the existing values' do
      expect { instance.merge other }.not_to change(instance, :to_h)
    end # it

    it 'should return a new results object with the totals' do
      totals = instance.merge other

      expect(totals).to be_a described_class

      %w(inspected_file_count offense_count).each do |prop|
        expect(totals.send prop).to be == instance.send(prop) + other.send(prop)
      end # each
    end # it
  end # describe

  describe '#offense_count' do
    include_examples 'should have reader',
      :offense_count,
      ->() { results['offense_count'] }

    wrap_examples 'when the results are empty' do
      it { expect(instance.offense_count).to be 0 }
    end # wrap_examples
  end # describe

  describe '#pending?' do
    include_examples 'should have predicate', :pending?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results have no examples' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results have no offenses' do
      it { expect(instance.pending?).to be false }
    end # wrap_context
  end # describe

  describe '#to_h' do
    it { expect(instance).to respond_to(:to_h).with(0).arguments }

    it { expect(instance.to_h).to be == results }

    wrap_context 'when the results are empty' do
      let(:expected) do
        {
          'inspected_file_count' => 0,
          'offense_count'        => 0
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
      str = "#{instance.inspected_file_count} files inspected"

      str << ", #{instance.offense_count} offenses"
    end # let

    it { expect(instance).to respond_to(:to_s).with(0).arguments }

    it { expect(instance.to_s).to be == expected }

    wrap_context 'when the results are empty' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context

    wrap_context 'when the results have no examples' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context

    wrap_context 'when the results have no offenses' do
      it { expect(instance.to_s).to be == expected }
    end # wrap_context
  end # describe
end # describe
