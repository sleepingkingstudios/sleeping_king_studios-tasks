# spec/sleeping_king_studios/tasks/ci/cucumber_parser_spec.rb

require 'sleeping_king_studios/tasks/ci/cucumber_parser'

RSpec.describe SleepingKingStudios::Tasks::Ci::CucumberParser do
  describe '::parse' do
    let(:results) { [] }
    let(:expected) do
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

    def build_feature_result
      scenarios = []

      yield scenarios if block_given?

      {
        'uri'      => 'features/example.feature',
        'elements' => scenarios
      } # end feature result
    end # method build_feature_result

    def build_scenario_result name: 'scenario'
      steps = []

      yield steps if block_given?

      {
        'line'    => 1,
        'keyword' => 'Scenario',
        'name'    => name,
        'steps'   => steps
      } # end scenario result
    end # method build_scenario_result

    def build_step_result status: 'passed'
      {
        'result' =>
          {
            'duration' => 10**7,
            'status'   => status
          }
      } # end step result
    end # method build_step_result

    it { expect(described_class).to respond_to(:parse).with(1).argument }

    describe 'with empty results' do
      it { expect(described_class.parse results).to be == expected }
    end # describe

    describe 'with a feature with one scenario with one passing step' do
      let(:results) do
        [
          build_feature_result do |scenarios|
            scenarios <<
              build_scenario_result do |steps|
                steps << build_step_result
              end # build_scenario_result
          end # build_feature_result
        ] # end results
      end # let
      let(:expected) do
        hsh = super()

        hsh['scenario_count'] = 1
        hsh['step_count']     = 1
        hsh['duration']       = 0.01

        hsh
      end # let

      it { expect(described_class.parse results).to be == expected }
    end # describe

    describe 'with a feature with one scenario with one pending step' do
      let(:results) do
        [
          build_feature_result do |scenarios|
            scenarios <<
              build_scenario_result(:name => 'pending scenario') do |steps|
                steps << build_step_result(:status => 'pending')
              end # build_scenario_result
          end # build_feature_result
        ] # end results
      end # let
      let(:expected) do
        hsh = super()

        hsh['scenario_count']     = 1
        hsh['step_count']         = 1
        hsh['duration']           = 0.01
        hsh['pending_step_count'] = 1

        hsh['pending_scenarios'] =
          [
            {
              'location'    => 'features/example.feature:1',
              'description' => 'Scenario: pending scenario'
            } # end scenario
          ] # end pending scenarios

        hsh
      end # let

      it { expect(described_class.parse results).to be == expected }
    end # describe

    describe 'with a feature with one scenario with one failing step' do
      let(:results) do
        [
          build_feature_result do |scenarios|
            scenarios <<
              build_scenario_result(:name => 'failing scenario') do |steps|
                steps << build_step_result(:status => 'failed')
              end # build_scenario_result
          end # build_feature_result
        ] # end results
      end # let
      let(:expected) do
        hsh = super()

        hsh['scenario_count']     = 1
        hsh['step_count']         = 1
        hsh['duration']           = 0.01
        hsh['failing_step_count'] = 1

        hsh['failing_scenarios'] =
          [
            {
              'location'    => 'features/example.feature:1',
              'description' => 'Scenario: failing scenario'
            } # end scenario
          ] # end failing scenarios

        hsh
      end # let

      it { expect(described_class.parse results).to be == expected }
    end # describe

    describe 'with a feature with one scenario with many steps' do
      let(:results) do
        scenario_name = 'scenario with many steps'

        [
          build_feature_result do |scenarios|
            scenarios <<
              build_scenario_result(:name => scenario_name) do |steps|
                steps << build_step_result(:status => 'passed')
                steps << build_step_result(:status => 'pending')
                steps << build_step_result(:status => 'failed')
                steps << build_step_result(:status => 'skipped')
              end # build_scenario_result
          end # build_feature_result
        ] # end results
      end # let
      let(:expected) do
        hsh = super()

        hsh['scenario_count']     = 1
        hsh['step_count']         = 4
        hsh['duration']           = 0.04
        hsh['pending_step_count'] = 2
        hsh['failing_step_count'] = 1

        hsh['failing_scenarios'] =
          [
            {
              'location'    => 'features/example.feature:1',
              'description' => 'Scenario: scenario with many steps'
            } # end scenario
          ] # end failing scenarios

        hsh
      end # let

      it { expect(described_class.parse results).to be == expected }
    end # describe

    describe 'with a feature with many scenarios' do
      let(:results) do
        [
          build_feature_result do |scenarios|
            scenarios <<
              build_scenario_result(:name => 'passing scenario') do |steps|
                steps << build_step_result(:status => 'passed')
              end # build_scenario_result
            scenarios <<
              build_scenario_result(:name => 'pending scenario') do |steps|
                steps << build_step_result(:status => 'pending')
              end # build_scenario_result
            scenarios <<
              build_scenario_result(:name => 'failing scenario') do |steps|
                steps << build_step_result(:status => 'failed')
              end # build_scenario_result
          end # build_feature_result
        ] # end results
      end # let
      let(:expected) do
        hsh = super()

        hsh['scenario_count']     = 3
        hsh['step_count']         = 3
        hsh['duration']           = 0.03
        hsh['pending_step_count'] = 1
        hsh['failing_step_count'] = 1

        hsh['pending_scenarios'] =
          [
            {
              'location'    => 'features/example.feature:1',
              'description' => 'Scenario: pending scenario'
            } # end scenario
          ] # end pending scenarios

        hsh['failing_scenarios'] =
          [
            {
              'location'    => 'features/example.feature:1',
              'description' => 'Scenario: failing scenario'
            } # end scenario
          ] # end failing scenarios

        hsh
      end # let

      it { expect(described_class.parse results).to be == expected }
    end # describe

    describe 'with loaded results' do
      let(:results) do
        raw = File.read 'spec/sleeping_king_studios/tasks/ci/cucumber.json'

        JSON.parse raw
      end # let
      let(:expected) do
        {
          'scenario_count' => 5,
          'failing_scenarios' =>
            [
              {
                'location'    => 'features/one_failing_many_steps.feature:2',
                'description' => 'Scenario: Passing Twice Then Failing'
              }, # end scenario
              {
                'location'    => 'features/one_passing_one_failing.feature:8',
                'description' => 'Scenario: Failing'
              } # end scenario
            ], # end failing scenarios
          'pending_scenarios' =>
            [
              {
                'location'    => 'features/one_passing_one_failing.feature:5',
                'description' => 'Scenario: Pending'
              } # end scenario
            ], # end pending scenarios
          'step_count'         => 9,
          'failing_step_count' => 2,
          'pending_step_count' => 1,
          'duration'           => 0.01062309
        } # end expected
      end # let

      it { expect(described_class.parse results).to be == expected }
    end # describe
  end # describe
end # describe
