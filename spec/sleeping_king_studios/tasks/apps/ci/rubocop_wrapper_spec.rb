# spec/sleeping_king_studios/tasks/apps/ci/rubocop_wrapper_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/rubocop_wrapper'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::RuboCopWrapper do
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
      data  = tools.hash.convert_keys_to_symbols(data)

      hsh[name] = SleepingKingStudios::Tasks::Apps::AppConfiguration.new(data)
    end # each
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    let(:source_files) { ['lib/app.rb', 'lib/app', 'path/to/app/spec'] }
    let(:results)      { double('results') }

    before(:example) do
      allow(instance).to receive(:applications).and_return(config)

      allow(instance).to receive(:run_step)

      allow(instance).to receive(:source_files).and_return(source_files)
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
        with(*source_files).
        and_return(results)

      expect(instance.call 'public').to be results
    end # it
  end # describe

  describe '#source_files' do
    let(:data) do
      {
        :source_files => source_files,
        :spec_files   => spec_files
      } # end data
    end # let
    let(:config) do
      SleepingKingStudios::Tasks::Apps::AppConfiguration.new(data)
    end # let
    let(:application)  { 'public' }
    let(:source_files) { ['path/to/app/lib'] }
    let(:spec_files)   { ['path/to/app/spec'] }
    let(:expected)     { source_files + spec_files }

    before(:example) do
      allow(instance).to receive(:current_application).and_return(application)

      allow(SleepingKingStudios::Tasks::Apps.configuration).
        to receive(:[]).
        with(application).
        and_return(config)
    end # before example

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:source_files)

      expect(instance).
        to respond_to(:source_files, true).
        with(0).arguments
    end # it

    it { expect(instance.send :source_files).to be == expected }
  end # describe

  describe '#step_key' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:step_key)

      expect(instance).
        to respond_to(:step_key, true).
        with(0).arguments
    end # it

    it { expect(instance.send :step_key).to be == :rubocop }
  end # describe
end # describe
