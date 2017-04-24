# spec/sleeping_king_studios/tasks/apps/ci/steps_runner_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/rspec_wrapper'
require 'sleeping_king_studios/tasks/apps/ci/steps_runner'
require 'sleeping_king_studios/tasks/ci/rspec_results'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::StepsRunner do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '#call' do
    shared_examples 'should return the results for each step' do
      describe 'should return the results for each step' do
        before(:example) do
          allow(instance).to receive(:ci_steps).and_return(expected_steps)

          expected_steps.each_value do |config|
            step_class = Object.const_get(config[:class])
            instance   = step_class.new(options)

            expect(step_class).
              to receive(:new).
              with(options).
              and_return(instance)

            expect(instance).
              to receive(:call).
              with(application).
              and_return(config[:results])
          end # each
        end # before example

        it do
          results = instance.call(application)

          expect(results).to be == expected_results
        end # it
      end # describe
    end # shared_examples

    let(:application) { 'public' }
    let(:rspec_results) do
      SleepingKingStudios::Tasks::Ci::RSpecResults.new(
        'duration'      => 1.0,
        'example_count' => 6,
        'failure_count' => 1,
        'pending_count' => 2
      ) # end rspec results
    end # let
    let(:expected_steps) do
      {
        'RSpec' => {
          :require => 'sleeping_king_studios/tasks/apps/ci/rspec_wrapper',
          :class   => 'SleepingKingStudios::Tasks::Apps::Ci::RSpecWrapper',
          :results => rspec_results
        } # end rspec
      } # end steps
    end # let
    let(:expected_results) do
      expected_steps.each.with_object({}) do |(name, step), hsh|
        hsh[name] = step[:results]
      end # each
    end # let

    it { expect(instance).to respond_to(:call).with(1).argument }

    include_examples 'should return the results for each step'
  end # describe

  describe '#ci_steps' do
    let(:expected_steps) do
      SleepingKingStudios::Tasks.configuration.apps.ci.steps_with_options
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:ci_steps)

      expect(instance).to respond_to(:ci_steps, true).with(0).arguments
    end # it

    it { expect(instance.send :ci_steps).to be == expected_steps }
  end # describe

  describe '#skip_step?' do
    let(:name)   { 'public' }
    let(:config) { {} }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:skip_step?)

      expect(instance).to respond_to(:skip_step?, true).with(2).arguments
    end # it

    it { expect(instance.send :skip_step?, name, config).to be false }

    describe 'with :global => true' do
      let(:config) { super().merge :global => true }

      it { expect(instance.send :skip_step?, name, config).to be true }
    end # describe

    context 'when options[:global] => true' do
      let(:options) { super().merge 'global' => true }

      it { expect(instance.send :skip_step?, name, config).to be true }

      describe 'with :global => true' do
        let(:config) { super().merge :global => true }

        it { expect(instance.send :skip_step?, name, config).to be false }
      end # describe
    end # context
  end # describe
end # describe
