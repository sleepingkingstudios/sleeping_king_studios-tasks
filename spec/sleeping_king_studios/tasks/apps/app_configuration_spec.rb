# spec/sleeping_king_studios/tasks/apps/apps_configuration_spec.rb

require 'sleeping_king_studios/tasks/apps/app_configuration'

RSpec.describe SleepingKingStudios::Tasks::Apps::AppConfiguration do
  let(:data)         { {} }
  let(:config_class) { SleepingKingStudios::Tools::Toolbox::Configuration }
  let(:instance)     { described_class.new(data) }

  describe '#ci' do
    it 'should define the namespace' do
      expect(instance).
        to have_reader(:ci).
        with_value(be_a config_class)
    end # it

    describe '#rspec' do
      it 'should define the option' do
        expect(instance.ci).to have_reader(:rspec).with_value({})
      end # it
    end # describe

    describe '#rubocop' do
      it 'should define the option' do
        expect(instance.ci).to have_reader(:rubocop).with_value({})
      end # it
    end # describe

    describe '#simplecov' do
      it 'should define the option' do
        expect(instance.ci).to have_reader(:simplecov).with_value({})
      end # it
    end # describe

    describe '#steps' do
      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:steps).
          with_value(%i[rspec rubocop simplecov])
      end # it

      context 'when the value is configured' do
        let(:steps) { %(jasmine jslint) }
        let(:data)  { super().merge :ci => { :steps => steps } }

        it { expect(instance.ci.steps).to be == steps }
      end # context
    end # describe

    describe '#steps_with_options' do
      let(:expected) do
        instance.ci.steps.each.with_object({}) do |step, hsh|
          value = instance.ci.send(step)

          next hsh[step] = false if value == false

          default   =
            SleepingKingStudios::Tasks.configuration.apps.ci.send(step)
          hsh[step] = default.merge(value)
        end # each
      end # let

      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:steps_with_options).
          with_value(be == expected)
      end # it

      context 'when a step value is configured' do
        before(:example) do
          instance.ci.rubocop = { 'title' => 'OcpLint' }
        end # before

        it { expect(instance.ci.steps_with_options).to be == expected }
      end # context

      context 'when a step value is set to false' do
        before(:example) do
          instance.ci.rubocop = false
        end # before

        it { expect(instance.ci.steps_with_options).to be == expected }
      end # context
    end # describe
  end # describe

  describe '#default_source_files' do
    let(:name) { 'Application Name' }
    let(:data) { { :name => name } }
    let(:expected) do
      [
        'apps/application_name',
        'apps/application_name.rb',
        'lib/application_name',
        'lib/application_name.rb'
      ] # end expected
    end # let

    it 'should define the method' do
      expect(instance).to respond_to(:default_source_files).with(0).arguments
    end # it

    it 'should return existing files matching the patterns' do
      expected.each do |path|
        expect(File).to receive(:exist?).with(path).and_return(true)
      end # each

      expect(instance.default_source_files).to be == expected
    end # it

    context 'when a file does not exist' do
      it 'should return existing files matching the patterns' do
        expected.each.with_index do |path, index|
          expect(File).to receive(:exist?).with(path).and_return(index.odd?)
        end # each

        expect(instance.default_source_files).
          to be == expected.each.select.with_index { |_, index| index.odd? }
      end # it
    end # context

    context 'when no files exist' do
      it 'should return an empty array' do
        expected.each do |path|
          expect(File).to receive(:exist?).with(path).and_return(false)
        end # each

        expect(instance.default_source_files).to be == []
      end # it
    end # context
  end # describe

  describe '#default_spec_files' do
    let(:name) { 'Application Name' }
    let(:data) { { :name => name } }
    let(:expected) do
      [
        'apps/application_name/spec',
        'spec/application_name'
      ] # end expected
    end # let

    it { expect(instance).to respond_to(:default_spec_files).with(0).arguments }

    it 'should return existing files matching the patterns' do
      expected.each do |path|
        expect(File).to receive(:exist?).with(path).and_return(true)
      end # each

      expect(instance.default_spec_files).to be == expected
    end # it

    context 'when a file does not exist' do
      it 'should return existing files matching the patterns' do
        expected.each.with_index do |path, index|
          expect(File).to receive(:exist?).with(path).and_return(index.odd?)
        end # each

        expect(instance.default_spec_files).
          to be == expected.each.select.with_index { |_, index| index.odd? }
      end # it
    end # context

    context 'when no files exist' do
      it 'should return an empty array' do
        expected.each do |path|
          expect(File).to receive(:exist?).with(path).and_return(false)
        end # each

        expect(instance.default_spec_files).to be == []
      end # it
    end # context
  end # describe

  describe '#gemfile' do
    it 'should define the option' do
      expect(instance).to have_reader(:gemfile).with_value(be == 'Gemfile')
    end # it

    context 'when the value is configured' do
      let(:gemfile) { 'path/to/gemfile' }
      let(:data)    { super().merge :gemfile => gemfile }

      it { expect(instance.gemfile).to be == gemfile }
    end # context
  end # describe

  describe '#name' do
    it 'should define the option' do
      expect(instance).to have_reader(:name).with_value(nil)
    end # it

    context 'when the value is configured' do
      let(:name) { 'Application Name' }
      let(:data) { super().merge :name => name }

      it { expect(instance.name).to be == name }
    end # context
  end # describe

  describe '#short_name' do
    let(:name) { 'Application Name' }
    let(:data) { { :name => name } }

    it 'should define the method' do
      expect(instance).to respond_to(:short_name).with(0).arguments
    end # it

    it { expect(instance.short_name).to be == 'application_name' }
  end # describe

  describe '#source_files' do
    let(:name) { 'Application Name' }
    let(:defaults) do
      [
        'apps/application_name',
        'apps/application_name.rb',
        'lib/application_name',
        'lib/application_name.rb'
      ] # end defaults
    end # let

    before(:example) do
      allow(instance).to receive(:default_source_files).and_return(defaults)
    end # before example

    it 'should define the option' do
      expect(instance).to have_reader(:source_files).with_value(defaults)
    end # it

    context 'when the value is configured' do
      let(:files) { ['app/application_name', 'app/application_name.rb'] }
      let(:data)  { super().merge :source_files => files }

      it { expect(instance.source_files).to be == files }
    end # context
  end # describe

  describe '#spec_files' do
    let(:name) { 'Application Name' }
    let(:defaults) do
      ['apps/application_name/spec', 'spec/application_name']
    end # let

    before(:example) do
      allow(instance).to receive(:default_spec_files).and_return(defaults)
    end # before example

    it 'should define the option' do
      expect(instance).to have_reader(:spec_files).with_value(defaults)
    end # it

    context 'when the value is configured' do
      let(:files) { ['test/application_name'] }
      let(:data)  { super().merge :spec_files => files }

      it { expect(instance.spec_files).to be == files }
    end # context
  end # describe
end # describe
