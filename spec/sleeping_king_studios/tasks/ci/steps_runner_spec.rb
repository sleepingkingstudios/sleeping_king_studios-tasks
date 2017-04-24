# spec/sleeping_king_studios/tasks/ci/steps_runner_spec.rb

require 'sleeping_king_studios/tasks/ci/steps_runner'

module Spec::Examples
  class FirstStep  < SleepingKingStudios::Tasks::Task; end
  class SecondStep < SleepingKingStudios::Tasks::Task; end
  class ThirdStep  < SleepingKingStudios::Tasks::Task; end
end # module

RSpec.describe SleepingKingStudios::Tasks::Ci::StepsRunner do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '#call' do
    shared_examples 'should return the results for each step' do
      describe 'should return the results for each step' do
        before(:example) do
          allow(instance).to receive(:ci_steps).and_return(expected_steps)

          allow(instance).to receive(:require_path).and_return(nil)

          expected_steps.each do |name, config|
            next if instance.send :skip_step?, name, config

            step_class = Object.const_get(config[:class])
            instance   = step_class.new(options)

            expect(step_class).
              to receive(:new).
              with(options).
              and_return(instance)

            expect(instance).
              to receive(:call).
              with(*expected_args).
              and_return(config[:results])
          end # each
        end # before example

        it do
          results = instance.call(*expected_args)

          expect(results).to be == expected_results
        end # it
      end # describe
    end # shared_examples

    let(:expected_args) { %w(first second third) }
    let(:expected_steps) do
      {
        '1st' => {
          :class   => 'Spec::Examples::FirstStep',
          :results => double('first results')
        }, # end first
        '2nd' => {
          :class   => 'Spec::Examples::SecondStep',
          :results => double('second results')
        }, # end second
        '3rd' => {
          :class   => 'Spec::Examples::ThirdStep',
          :results => double('third results')
        } # end third
      } # end steps
    end # let
    let(:expected_results) do
      expected_steps.each.with_object({}) do |(name, step), hsh|
        hsh[name] = step[:results]
      end # each
    end # let

    it { expect(instance).to respond_to(:call).with(1).argument }

    include_examples 'should return the results for each step'

    context 'when a step is skipped' do
      let(:expected_results) do
        super().tap { |hsh| hsh.delete '2nd' }
      end # let

      before(:example) do
        allow(instance).to receive(:skip_step?) do |name, _|
          name == '2nd'
        end # allow
      end # before example

      include_examples 'should return the results for each step'
    end # context
  end # describe

  describe '#ci_steps' do
    it 'should define the private method' do
      expect(instance).not_to respond_to(:ci_steps)

      expect(instance).to respond_to(:ci_steps, true).with(0).arguments
    end # it

    it { expect(instance.send :ci_steps).to be == [] }
  end # describe

  describe '#skip_step?' do
    it 'should define the private method' do
      expect(instance).not_to respond_to(:skip_step?)

      expect(instance).to respond_to(:skip_step?, true).with(2).arguments
    end # it

    it { expect(instance.send :skip_step?, 'public', {}).to be false }
  end # describe
end # describe
