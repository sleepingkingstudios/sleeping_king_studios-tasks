# spec/sleeping_king_studios/tasks/apps/ci/step_wrapper_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/step_wrapper'
require 'sleeping_king_studios/tasks/ci/rubocop_task'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::StepWrapper do
  let(:described_class) do
    Class.new(super()) do
      def step_key; end
    end # class
  end # let
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }
  let(:applications) do
    {
      'admin'   => {},
      'public'  => {},
      'reports' => {}
    } # end applications
  end # let
  let(:config) do
    applications.each.with_object({}) do |(name, data), hsh|
      tools = SleepingKingStudios::Tools::Toolbelt.instance
      data  = tools.hsh.convert_keys_to_symbols(data)

      hsh[name] = SleepingKingStudios::Tasks::Apps::AppConfiguration.new(data)
    end # each
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#build_step' do
    let(:step) { :rubocop }
    let(:config) do
      SleepingKingStudios::Tasks.configuration.ci.steps_with_options.fetch(step)
    end # let
    let(:expected_class) { Object.const_get(config.fetch :class) }
    let(:expected_step)  { double('step') }

    before(:example) do
      allow(instance).to receive(:step_config).and_return(config)
    end # before example

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_step)

      expect(instance).
        to respond_to(:build_step, true).
        with(0).arguments
    end # it

    it 'should build an instance of the step' do
      expect(expected_class).
        to receive(:new).
        with(instance.send :step_options).
        and_return(expected_step)

      expect(instance.send :build_step).to be expected_step
    end # it
  end # describe

  describe '#call' do
    it 'should define the method' do
      expect(instance).
        to respond_to(:call).
        with(1).argument.
        and_unlimited_arguments
    end # it

    it 'should cache the current application' do
      expect { instance.call('public') }.
        to change(instance, :current_application).
        to be == 'public'
    end # it
  end # describe

  describe '#current_application' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:current_application)

      expect(instance).
        to respond_to(:current_application, true).
        with(0).arguments
    end # it

    it { expect(instance.send :current_application).to be nil }
  end # describe

  describe '#run_step' do
    let(:step_instance) { double('step', :call => true) }
    let(:step_args)     { %w[ichi ni san] }
    let(:step_kwargs)   { { :yon => 'go' } }
    let(:results)       { double('results') }

    before(:example) do
      allow(instance).to receive(:skip_step?).and_return(false)
    end # before example

    it 'should define the private method' do
      expect(instance).not_to respond_to(:run_step)

      expect(instance).to respond_to(:run_step, true).with_unlimited_arguments
    end # it

    it 'should build and call the step' do
      expect(instance).to receive(:build_step).and_return(step_instance)

      expect(step_instance).
        to receive(:call).
        with(*step_args, **step_kwargs).
        and_return(results)

      expect(instance.send :run_step, *step_args, **step_kwargs).to be results
    end # it

    context 'when the step is skipped' do
      before(:example) do
        allow(instance).to receive(:skip_step?).and_return(true)
      end # before example

      it 'should not build or call the step' do
        expect(instance).not_to receive(:build_step)

        expect(instance.send :run_step, *step_args, **step_kwargs).to be nil
      end # it
    end # context
  end # describe

  describe '#skip_step?' do
    let(:config) { {} }

    before(:example) do
      allow(instance).to receive(:step_config).and_return(config)
    end # before

    it 'should define the private predicate' do
      expect(instance).not_to respond_to(:skip_step?)

      expect(instance).
        to respond_to(:skip_step?, true).
        with(0).arguments
    end # it

    it { expect(instance.send :skip_step?).to be false }

    context 'when the configuration disables a step' do
      let(:config) { false }

      it { expect(instance.send :skip_step?).to be true }
    end # context
  end # describe

  describe '#step_config' do
    let(:step) { instance.send :step_key }
    let(:expected) do
      SleepingKingStudios::Tasks.configuration.ci.steps_with_options.fetch(step)
    end # let

    before(:example) do
      allow(instance).to receive(:applications).and_return(config)

      allow(instance).to receive(:current_application).and_return('public')

      allow(instance).to receive(:step_key).and_return(:rubocop)
    end # before example

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:step_config)

      expect(instance).
        to respond_to(:step_config, true).
        with(0).arguments
    end # it

    it 'should return the configured value' do
      expect(instance.send :step_config).to be == expected
    end # it
  end # describe

  describe '#step_options' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:step_options)

      expect(instance).
        to respond_to(:step_options, true).
        with(0).arguments
    end # it

    it { expect(instance.send :step_options).to be == options }

    context 'when options are set for the wrapper' do
      let(:options) { super().merge 'custom' => 'value' }

      it { expect(instance.send :step_options).to be == options }
    end # context
  end # describe
end # describe
