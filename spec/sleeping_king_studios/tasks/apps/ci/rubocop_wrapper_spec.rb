# spec/sleeping_king_studios/tasks/apps/ci/rubocop_wrapper_spec.rb

require 'sleeping_king_studios/tasks/apps/ci/rubocop_wrapper'

RSpec.describe SleepingKingStudios::Tasks::Apps::Ci::RuboCopWrapper do
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
    let(:src_files) { ['lib/app.rb', 'lib/app'] }
    let(:spec_dir)  { ['path/to/app/spec'] }
    let(:results)   { double('results') }

    before(:example) do
      allow(instance).to receive(:applications).and_return(applications)

      allow(instance).to receive(:run_step)

      allow(instance).to receive(:source_files).and_return(src_files)

      allow(instance).to receive(:spec_directories).and_return(spec_dir)
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
        with(*src_files, *spec_dir).
        and_return(results)

      expect(instance.call 'public').to be results
    end # it
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
