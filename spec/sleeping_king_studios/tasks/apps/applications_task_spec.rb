# spec/sleeping_king_studios/tasks/apps/applications_task_spec.rb

require 'sleeping_king_studios/tasks/apps/applications_task'

RSpec.describe SleepingKingStudios::Tasks::Apps::ApplicationsTask do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  it { expect(described_class).to be < SleepingKingStudios::Tasks::Task }

  describe '#applications' do
    let(:raw) do
      <<-YAML
admin: {}
public: {}
reports: {}
      YAML
    end # let
    let(:expected) { YAML.safe_load(raw) }

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:applications)

      expect(instance).to respond_to(:applications, true).with(0).arguments
    end # it

    it 'should load and parse the config file' do
      expect(File).
        to receive(:read).
        with(instance.send(:config_file)).
        and_return(raw)

      config = instance.send(:applications)

      expect(config).to be == expected
    end # it
  end # describe

  describe '#config_file' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:config_file)

      expect(instance).to respond_to(:config_file, true).with(0).arguments
    end # it

    it 'should return the configured value' do
      expect(instance.send :config_file).
        to be == SleepingKingStudios::Tasks.configuration.apps.config_file
    end # it
  end # describe
end # describe
