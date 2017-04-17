# spec/sleeping_king_studios/tasks/configuration_spec.rb

require 'sleeping_king_studios/tasks/configuration'

RSpec.describe SleepingKingStudios::Tasks::Configuration do
  let(:data)         { {} }
  let(:config_class) { SleepingKingStudios::Tools::Toolbox::Configuration }
  let(:instance)     { described_class.new(data) }

  describe '#apps' do
    it 'should define the namespace' do
      expect(instance).
        to have_reader(:apps).
        with_value(be_a config_class)
    end # it

    describe '#config_file' do
      it 'should define the option' do
        expect(instance.apps).
          to have_reader(:config_file).
          with_value(be == 'applications.yml')
      end # it
    end # describe
  end # describe

  describe '#ci' do
    it 'should define the namespace' do
      expect(instance).
        to have_reader(:ci).
        with_value(be_a config_class)
    end # it

    describe '#rspec' do
      let(:expected) do
        {
          :require => 'sleeping_king_studios/tasks/ci/rspec',
          :class   => 'SleepingKingStudios::Tasks::Ci::RSpec',
          :title   => 'RSpec'
        } # end rspec
      end # let

      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:rspec).
          with_value(be == expected)
      end # it
    end # describe

    describe '#rspec_each' do
      let(:expected) do
        {
          :require => 'sleeping_king_studios/tasks/ci/rspec_each',
          :class   => 'SleepingKingStudios::Tasks::Ci::RSpecEach',
          :title   => 'RSpec (Each)'
        } # end rspec
      end # let

      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:rspec_each).
          with_value(be == expected)
      end # it
    end # describe

    describe '#rubocop' do
      let(:expected) do
        {
          :require => 'sleeping_king_studios/tasks/ci/rubocop',
          :class   => 'SleepingKingStudios::Tasks::Ci::RuboCop',
          :title   => 'RuboCop'
        } # end rubocop
      end # let

      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:rubocop).
          with_value(be == expected)
      end # it
    end # describe

    describe '#simplecov' do
      let(:expected) do
        {
          :require => 'sleeping_king_studios/tasks/ci/simplecov',
          :class   => 'SleepingKingStudios::Tasks::Ci::SimpleCov',
          :title   => 'SimpleCov'
        } # end simplecov
      end # let

      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:simplecov).
          with_value(be == expected)
      end # it
    end # describe

    describe '#steps' do
      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:steps).
          with_value(%i(rspec rubocop simplecov))
      end # it
    end # describe

    describe '#steps_with_options' do
      let(:expected) do
        instance.ci.steps.each.with_object({}) do |step, hsh|
          hsh[step] = instance.ci.send(step)
        end # each
      end # let

      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:steps_with_options).
          with_value(be == expected)
      end # it
    end # describe
  end # describe

  describe '#file' do
    it 'should define the namespace' do
      expect(instance).
        to have_reader(:file).
        with_value(be_a config_class)
    end # it

    describe '::default_template_path' do
      let(:expected) do
        relative_path =
          File.join(
            SleepingKingStudios::Tasks.gem_path,
            'lib',
            'sleeping_king_studios',
            'tasks',
            'file',
            'templates'
          ) # end join

        File.expand_path(relative_path)
      end # let

      it 'should define the class method' do
        expect(instance.file.class).
          to have_reader(:default_template_path).
          with_value(be == expected)
      end # it
    end # describe

    describe '#template_paths' do
      let(:expected) do
        relative_path =
          File.join(
            SleepingKingStudios::Tasks.gem_path,
            'lib',
            'sleeping_king_studios',
            'tasks',
            'file',
            'templates'
          ) # end join

        [File.expand_path(relative_path)]
      end # let

      it 'should define the option' do
        expect(instance.file).
          to have_reader(:template_paths).
          with_value(expected)
      end # it

      context 'when the value is configured' do
        let(:data) do
          super().merge :file => { :template_paths => ['path/to/templates'] }
        end # let

        it 'should define the option' do
          expect(instance.file).
            to have_reader(:template_paths).
            with_value(data[:file][:template_paths])
        end # it
      end # context
    end # describe
  end # describe
end # describe
