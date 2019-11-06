# spec/sleeping_king_studios/tasks/apps_spec.rb

require 'sleeping_king_studios/tasks/apps'

RSpec.describe SleepingKingStudios::Tasks::Apps do
  describe '::configuration' do
    let(:applications) { {} }

    before(:example) do
      allow(described_class).
        to receive(:load_configuration).
        and_return(applications)
    end # before example

    around(:example) do |example|
      begin
        described_class.instance_variable_set :@configuration, nil

        example.call
      ensure
        described_class.instance_variable_set :@configuration, nil
      end # begin-ensure
    end # around example

    it 'should define the class reader' do
      expect(described_class).
        to have_reader(:configuration).
        with_value(be == {})
    end # it

    describe 'when the file configures applications' do
      let(:applications) do
        {
          'admin'   => {},
          'public'  => {},
          'reports' => {}
        } # end let
      end # let

      it 'should create configuration objects for each application' do
        hsh = described_class.configuration

        applications.each_key do |key|
          config = hsh[key]

          expect(config).
            to be_a SleepingKingStudios::Tasks::Apps::AppConfiguration
          expect(config.name).to be == key
        end # each
      end # it

      context 'when the data configures an application' do
        let(:gemfile) { 'path/to/gemfile' }
        let(:applications) do
          hsh = super()

          hsh['public']['name']    = 'Public'
          hsh['public']['gemfile'] = gemfile

          hsh
        end # let

        it 'should create configuration objects for each application' do
          hsh    = described_class.configuration
          config = hsh['public']

          expect(config).
            to be_a SleepingKingStudios::Tasks::Apps::AppConfiguration
          expect(config.name).to be == 'Public'
          expect(config.gemfile).to be == gemfile
        end # it
      end # context
    end # describe
  end # describe

  describe '::load_configuration' do
    let(:config_file) do
      SleepingKingStudios::Tasks.configuration.apps.config_file
    end # let
    let(:raw) do
      <<~YAML
        config:
          key: 'value'
      YAML
    end # let
    let(:expected) { YAML.safe_load(raw) }

    it 'should define the private class method' do
      expect(described_class).not_to respond_to(:load_configuration)

      expect(described_class).
        to respond_to(:load_configuration, true).
        with(0).arguments
    end # it

    it 'should load the applications configuration' do
      expect(File).to receive(:read).with(config_file).and_return(raw)

      expect(described_class.send :load_configuration).to be == expected
    end # it
  end # describe
end # describe
