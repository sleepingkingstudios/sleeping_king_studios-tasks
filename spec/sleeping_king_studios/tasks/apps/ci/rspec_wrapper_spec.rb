# spec/sleeping_king_studios/tasks/apps/ci/rspec_wrapper_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/rspec_wrapper'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::RSpecWrapper do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    let(:applications) do
      {
        'admin'   => {},
        'public'  => {},
        'reports' => {}
      } # end applications
    end # let
    let(:expected_args) { ['path/to/app/spec'] }
    let(:results)       { double('results') }

    before(:example) do
      allow(instance).to receive(:applications).and_return(applications)

      allow(instance).to receive(:run_step)

      allow(instance).to receive(:spec_directories).and_return(expected_args)
    end # before example

    it { expect(instance).to respond_to(:call).with(1).argument }

    it 'should cache the current application' do
      expect { instance.call('public') }.
        to change(instance, :current_application).
        to be == 'public'
    end # it

    it 'should build and call the step' do
      expect(instance).
        to receive(:run_step).
        with(*expected_args).
        and_return(results)

      expect(instance.call 'public').to be results
    end # it

    context 'when there are no valid spec directories' do
      let(:expected_args) { [] }

      it 'should return empty results' do
        expect(instance).not_to receive(:run_step)

        results = instance.call('public')

        expect(results).to be_a SleepingKingStudios::Tasks::Ci::RSpecResults
        expect(results.empty?).to be true
      end # it
    end # context
  end # describe

  describe '#step_key' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:step_key)

      expect(instance).
        to respond_to(:step_key, true).
        with(0).arguments
    end # it

    it { expect(instance.send :step_key).to be == :rspec }
  end # describe

  describe '#step_options' do
    let(:applications) do
      {
        'admin'   => {},
        'public'  => {},
        'reports' => {}
      } # end applications
    end # let
    let(:gemfile)  { 'Gemfile' }
    let(:expected) do
      {
        'coverage' => true,
        'gemfile'  => gemfile,
        '__env__'  => { :app_name => 'public' }
      } # expected
    end # let

    before(:example) do
      allow(instance).to receive(:applications).and_return(applications)

      allow(instance).to receive(:current_application).and_return('public')
    end # before example

    it { expect(instance.send :step_options).to be == expected }

    context 'when a gemfile is configured for the application' do
      let(:gemfile) { 'path/to/gemfile' }
      let(:applications) do
        hsh = super()

        hsh['public']['gemfile'] = gemfile

        hsh
      end # let

      it { expect(instance.send :step_options).to be == expected }
    end # context

    context 'when options are set for the wrapper' do
      let(:options)  { super().merge 'custom' => 'value' }
      let(:expected) { options.merge super() }

      it { expect(instance.send :step_options).to be == expected }
    end # context
  end # describe
end # describe
