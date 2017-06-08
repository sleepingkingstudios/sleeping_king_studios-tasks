# spec/sleeping_king_studios/tasks/ci/cucumber_results_spec.rb

require 'sleeping_king_studios/tasks/ci/cucumber_results'

RSpec.describe SleepingKingStudios::Tasks::Ci::CucumberResults do
  shared_context 'when the results are empty' do
    let(:results) { {} }
  end # shared_context

  shared_context 'when the results are pending' do
    let(:results) do
      hsh = super()

      hsh['pending_scenarios'] =
        [
          {
            'location'    => 'features/example.feature:1',
            'description' => 'Scenario: pending scenario'
          } # end scenario
        ] # end pending scenarios
      hsh['pending_step_count'] = 1

      hsh
    end # let
  end # shared_context

  shared_context 'when the results are failing' do
    let(:results) do
      hsh = super()

      hsh['failing_scenarios'] =
        [
          {
            'location'    => 'features/example.feature:1',
            'description' => 'Scenario: failing scenario'
          } # end scenario
        ] # end pending scenarios
      hsh['failing_step_count'] = 1

      hsh
    end # let
  end # shared_context

  shared_context 'when the results are pending and failing' do
    let(:results) do
      hsh = super()

      hsh['pending_scenarios'] =
        [
          {
            'location'    => 'features/example.feature:1',
            'description' => 'Scenario: pending scenario'
          } # end scenario
        ] # end pending scenarios
      hsh['pending_step_count'] = 1
      hsh['failing_scenarios'] =
        [
          {
            'location'    => 'features/example.feature:1',
            'description' => 'Scenario: failing scenario'
          } # end scenario
        ] # end pending scenarios
      hsh['failing_step_count'] = 1

      hsh
    end # let
  end # shared_context

  shared_context 'when the results have no scenarios' do
    let(:results) do
      {
        'scenario_count'     => 0,
        'failing_scenarios'  => [],
        'pending_scenarios'  => [],
        'step_count'         => 0,
        'failing_step_count' => 0,
        'pending_step_count' => 0,
        'duration'           => 0.0
      } # end report
    end # let
  end # shared_context

  let(:results) do
    {
      'scenario_count'     => 3,
      'failing_scenarios'  => [],
      'pending_scenarios'  => [],
      'step_count'         => 3,
      'failing_step_count' => 0,
      'pending_step_count' => 0,
      'duration'           => 0.3
    } # end report
  end # let
  let(:instance) { described_class.new(results) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#==' do
    let(:other) do
      described_class.new(
        'scenario_count'     => 3,
        'failing_scenarios'  => [],
        'pending_scenarios'  => [],
        'step_count'         => 3,
        'failing_step_count' => 0,
        'pending_step_count' => 0,
        'duration'           => 0.3
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

      describe 'with a results object with no scenarios' do
        let(:other) do
          described_class.new(
            'scenario_count'     => 0,
            'failing_scenarios'  => [],
            'pending_scenarios'  => [],
            'step_count'         => 0,
            'failing_step_count' => 0,
            'pending_step_count' => 0,
            'duration'           => 0.0
          ) # end other
        end # let

        it { expect(instance).to be == other }
      end # describe
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance).not_to be == other }
    end # wrap_context

    wrap_context 'when the results are failing' do
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

    wrap_context 'when the results have no scenarios' do
      it { expect(instance.empty?).to be true }
    end # wrap_context
  end # describe

  describe '#failing?' do
    include_examples 'should have predicate', :failing?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results have no scenarios' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.failing?).to be false }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance.failing?).to be true }
    end # wrap_context
  end # describe

  describe '#failing_scenarios' do
    include_examples 'should have reader',
      :failing_scenarios,
      ->() { results['failing_scenarios'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.failing_scenarios).to be == [] }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it 'should return the value' do
        expect(instance.failing_scenarios).to be results['failing_scenarios']
      end # it
    end # wrap_context
  end # describe

  describe '#failing_scenario_count' do
    include_examples 'should have reader',
      :failing_scenario_count,
      ->() { results['failing_scenarios'].count }

    wrap_context 'when the results are empty' do
      it { expect(instance.failing_scenario_count).to be 0 }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it 'should return the count' do
        expect(instance.failing_scenario_count).
          to be results['failing_scenarios'].count
      end # it
    end # wrap_context
  end # describe

  describe '#failing_step_count' do
    include_examples 'should have reader',
      :failing_step_count,
      ->() { results['failing_step_count'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.failing_step_count).to be 0 }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it 'should return the value' do
        expect(instance.failing_step_count).to be results['failing_step_count']
      end # it
    end # wrap_context
  end # describe

  describe '#merge' do
    let(:other) do
      described_class.new(
        'scenario_count'     => 3,
        'failing_scenarios'  => [],
        'pending_scenarios'  =>
          [
            {
              'location'    => 'features/example.feature:1',
              'description' => 'Scenario: pending scenario'
            } # end scenario
          ], # end pending scenarios
        'step_count'         => 3,
        'failing_step_count' => 0,
        'pending_step_count' => 1,
        'duration'           => 0.3
      ) # end other
    end # let

    it { expect(instance).to respond_to(:merge).with(1).argument }

    it 'should not change the existing values' do
      expect { instance.merge other }.not_to change(instance, :to_h)
    end # it

    it 'should return a new results object with the totals' do
      totals = instance.merge other

      expect(totals).to be_a described_class

      %w(
        duration
        scenario_count
        failing_scenarios
        pending_scenarios
        step_count
        failing_step_count
        pending_step_count
      ).each do |prop|
        expect(totals.send prop).to be == instance.send(prop) + other.send(prop)
      end # each
    end # it
  end # describe

  describe '#pending?' do
    include_examples 'should have predicate', :pending?, false

    wrap_context 'when the results are empty' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results have no scenarios' do
      it { expect(instance.pending?).to be false }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.pending?).to be true }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance.pending?).to be false }
    end # wrap_context
  end # describe

  describe '#pending_scenario_count' do
    include_examples 'should have reader',
      :pending_scenario_count,
      ->() { results['pending_scenarios'].count }

    wrap_context 'when the results are empty' do
      it { expect(instance.pending_scenario_count).to be 0 }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it 'should return the count' do
        expect(instance.pending_scenario_count).
          to be results['pending_scenarios'].count
      end # it
    end # wrap_context
  end # describe

  describe '#pending_scenarios' do
    include_examples 'should have reader',
      :pending_scenarios,
      ->() { results['pending_scenarios'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.pending_scenarios).to be == [] }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it 'should return the value' do
        expect(instance.pending_scenarios).to be results['pending_scenarios']
      end # it
    end # wrap_context
  end # describe

  describe '#pending_step_count' do
    include_examples 'should have reader',
      :pending_step_count,
      ->() { results['pending_step_count'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.pending_step_count).to be 0 }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it 'should return the value' do
        expect(instance.pending_step_count).to be results['pending_step_count']
      end # it
    end # wrap_context
  end # describe

  describe '#scenario_count' do
    include_examples 'should have reader',
      :scenario_count,
      ->() { results['scenario_count'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.scenario_count).to be 0 }
    end # wrap_context
  end # describe

  describe '#scenarios_summary' do
    let(:expected) { "#{instance.scenario_count} scenarios" }

    it { expect(instance).to respond_to(:scenarios_summary).with(0).arguments }

    it { expect(instance.scenarios_summary).to be == expected }

    wrap_context 'when the results have no scenarios' do
      it { expect(instance.scenarios_summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are empty' do
      it { expect(instance.scenarios_summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are pending' do
      let(:expected) do
        "#{super()} (#{instance.pending_scenario_count} pending)"
      end # let

      it { expect(instance.scenarios_summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are failing' do
      let(:expected) do
        "#{super()} (#{instance.failing_scenario_count} failure)"
      end # let

      it { expect(instance.scenarios_summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are pending and failing' do
      let(:expected) do
        str = super()

        str << ' ('
        str << "#{instance.failing_scenario_count} failure"
        str << ', '
        str << "#{instance.pending_scenario_count} pending"
        str << ')'
      end # let

      it { expect(instance.scenarios_summary).to be == expected }
    end # wrap_context
  end # describe

  describe '#step_count' do
    include_examples 'should have reader',
      :step_count,
      ->() { results['step_count'] }

    wrap_context 'when the results are empty' do
      it { expect(instance.step_count).to be 0 }
    end # wrap_context
  end # describe

  describe '#steps_summary' do
    let(:expected) { "#{instance.step_count} steps" }

    it { expect(instance).to respond_to(:steps_summary).with(0).arguments }

    it { expect(instance.steps_summary).to be == expected }

    wrap_context 'when the results have no scenarios' do
      it { expect(instance.steps_summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are empty' do
      it { expect(instance.steps_summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are pending' do
      let(:expected) do
        "#{super()} (#{instance.pending_step_count} pending)"
      end # let

      it { expect(instance.steps_summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are failing' do
      let(:expected) do
        "#{super()} (#{instance.failing_step_count} failure)"
      end # let

      it { expect(instance.steps_summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are pending and failing' do
      let(:expected) do
        str = super()

        str << ' ('
        str << "#{instance.failing_step_count} failure"
        str << ', '
        str << "#{instance.pending_step_count} pending"
        str << ')'
      end # let

      it { expect(instance.steps_summary).to be == expected }
    end # wrap_context
  end # describe

  describe '#summary' do
    let(:expected) do
      str = instance.scenarios_summary

      str << ', '

      str << instance.steps_summary

      str << " in #{instance.duration.round(2)} seconds"
    end # let

    it { expect(instance).to respond_to(:summary).with(0).arguments }

    it { expect(instance).to alias_method(:summary).as(:to_s) }

    it { expect(instance.summary).to be == expected }

    wrap_context 'when the results have no scenarios' do
      it { expect(instance.summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are empty' do
      it { expect(instance.summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are pending' do
      it { expect(instance.summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are failing' do
      it { expect(instance.summary).to be == expected }
    end # wrap_context

    wrap_context 'when the results are pending and failing' do
      it { expect(instance.summary).to be == expected }
    end # wrap_context
  end # describe

  describe '#to_h' do
    it { expect(instance).to respond_to(:to_h).with(0).arguments }

    it { expect(instance.to_h).to be == results }

    wrap_context 'when the results are empty' do
      let(:expected) do
        {
          'duration'           => 0.0,
          'step_count'         => 0,
          'pending_step_count' => 0,
          'failing_step_count' => 0,
          'scenario_count'     => 0,
          'pending_scenarios'  => [],
          'failing_scenarios'  => []
        } # end hash
      end # let

      it { expect(instance.to_h).to be == expected }
    end # wrap_context

    wrap_context 'when the results have no scenarios' do
      it { expect(instance.to_h).to be == results }
    end # wrap_context
  end # describe
end # describe
