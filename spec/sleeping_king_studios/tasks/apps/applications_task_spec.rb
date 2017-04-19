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

  describe '#ci_step_config' do
    let(:name) { 'public' }
    let(:step) { :rubocop }
    let(:applications) do
      {
        'admin'   => {},
        'public'  => {},
        'reports' => {}
      } # end applications
    end # let
    let(:expected) do
      SleepingKingStudios::Tasks.configuration.ci.steps_with_options.fetch(step)
    end # let

    before(:example) do
      allow(instance).to receive(:applications).and_return(applications)
    end # before example

    it 'should define the private method' do
      expect(instance).not_to respond_to(:ci_step_config)

      expect(instance).to respond_to(:ci_step_config, true).with(2).arguments
    end # it

    it 'should return the configured value' do
      expect(instance.send :ci_step_config, name, step).to be == expected
    end # it

    context 'when the configuration disables a step' do
      let(:applications) do
        hsh = super()

        hsh['public'] = { 'ci' => { 'rubocop' => false } }

        hsh
      end # let

      it 'should return false' do
        expect(instance.send :ci_step_config, name, step).to be false
      end # it
    end # context

    context 'when the configuration updates a step' do
      let(:applications) do
        hsh = super()

        hsh['public'] = { 'ci' => { 'rubocop' => { 'title' => 'OcpLint' } } }

        hsh
      end # let
      let(:expected) do
        super().merge :title => 'OcpLint'
      end # let

      it 'should return the updated value' do
        expect(instance.send :ci_step_config, name, step).to be == expected
      end # it
    end # context
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

  describe '#filter_applications' do
    let(:applications) do
      {
        'admin'   => {},
        'public'  => {},
        'reports' => {}
      } # end applications
    end # let
    let(:expected) { applications }

    before(:example) do
      allow(instance).to receive(:applications).and_return(applications)
    end # before example

    it 'should define the private method' do
      expect(instance).not_to respond_to(:filter_applications)

      expect(instance).
        to respond_to(:filter_applications, true).
        with(0).arguments.
        and_keywords(:only)
    end # it

    it 'should filter the applications' do
      expect(instance.send :filter_applications, :only => []).to be == expected
    end # it

    describe 'with :only => applications' do
      let(:only) { %w(admin reports) }
      let(:expected) do
        {
          'admin'   => {},
          'reports' => {}
        } # end applications
      end # let

      it 'should filter the applications' do
        expect(instance.send :filter_applications, :only => only).
          to be == expected
      end # it
    end # describe
  end # describe

  describe '#source_files' do
    let(:name)   { 'application_name' }
    let(:config) { {} }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:source_files)

      expect(instance).to respond_to(:source_files, true).with(2).arguments
    end # it

    it 'should return existing files' do
      expect(File).
        to receive(:exist?).
        with("apps/#{name}.rb").
        and_return(true)

      expect(File).
        to receive(:exist?).
        with("apps/#{name}").
        and_return(true)

      expect(File).
        to receive(:exist?).
        with("lib/#{name}.rb").
        and_return(false)

      expect(File).
        to receive(:exist?).
        with("lib/#{name}").
        and_return(false)

      expect(instance.send :source_files, name, config).
        to be == ["apps/#{name}.rb", "apps/#{name}"]
    end # it

    context 'when the configured value is an array' do
      let(:config)   { { 'source_files' => expected } }
      let(:expected) { ['path/to/lib'] }

      it 'should return the configured value' do
        expect(instance.send :source_files, name, config).to be == expected
      end # it
    end # context

    context 'when the configured value is a string' do
      let(:config)   { { 'source_files' => expected.first } }
      let(:expected) { ['path/to/lib'] }

      it 'should return the configured value' do
        expect(instance.send :source_files, name, config).to be == expected
      end # it
    end # context
  end # describe

  describe '#spec_directories' do
    let(:name)   { 'application_name' }
    let(:config) { {} }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:spec_directories)

      expect(instance).to respond_to(:spec_directories, true).with(2).arguments
    end # it

    it 'should return existing directories' do
      expect(File).
        to receive(:directory?).
        with("spec/#{name}").
        and_return(false)

      expect(File).
        to receive(:directory?).
        with("apps/#{name}/spec").
        and_return(true)

      expect(instance.send :spec_directories, name, config).
        to be == ["apps/#{name}/spec"]
    end # it

    context 'when the configured value is an array' do
      let(:config)   { { 'spec_dir' => expected } }
      let(:expected) { ['path/to/spec'] }

      it 'should return the configured value' do
        expect(instance.send :spec_directories, name, config).to be == expected
      end # it
    end # context

    context 'when the configured value is a string' do
      let(:config)   { { 'spec_dir' => expected.first } }
      let(:expected) { ['path/to/spec'] }

      it 'should return the configured value' do
        expect(instance.send :spec_directories, name, config).to be == expected
      end # it
    end # context
  end # describe
end # describe
