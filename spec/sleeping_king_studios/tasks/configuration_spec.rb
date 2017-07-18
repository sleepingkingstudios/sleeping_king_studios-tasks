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

    describe '#ci' do
      it 'should define the namespace' do
        expect(instance.apps).
          to have_reader(:ci).
          with_value(be_a config_class)
      end # it

      describe '#rspec' do
        let(:expected) do
          {
            :require => 'sleeping_king_studios/tasks/apps/ci/rspec_wrapper',
            :class   => 'SleepingKingStudios::Tasks::Apps::Ci::RSpecWrapper',
            :title   => 'RSpec'
          } # end rspec
        end # let

        it 'should define the option' do
          expect(instance.apps.ci).
            to have_reader(:rspec).
            with_value(be == expected)
        end # it
      end # describe

      describe '#rubocop' do
        let(:expected) do
          {
            :require => 'sleeping_king_studios/tasks/apps/ci/rubocop_wrapper',
            :class   => 'SleepingKingStudios::Tasks::Apps::Ci::RuboCopWrapper',
            :title   => 'RuboCop'
          } # end rspec
        end # let

        it 'should define the option' do
          expect(instance.apps.ci).
            to have_reader(:rubocop).
            with_value(be == expected)
        end # it
      end # describe

      describe '#simplecov' do
        let(:expected) do
          {
            :require => 'sleeping_king_studios/tasks/apps/ci/simplecov_task',
            :class   => 'SleepingKingStudios::Tasks::Apps::Ci::SimpleCovTask',
            :title   => 'SimpleCov',
            :global  => true
          } # end rspec
        end # let

        it 'should define the option' do
          expect(instance.apps.ci).
            to have_reader(:simplecov).
            with_value(be == expected)
        end # it
      end # describe

      describe '#steps' do
        it 'should define the option' do
          expect(instance.apps.ci).
            to have_reader(:steps).
            with_value(%i(rspec rubocop simplecov))
        end # it
      end # describe

      describe '#steps_with_options' do
        let(:expected) do
          instance.apps.ci.steps.each.with_object({}) do |step, hsh|
            hsh[step] = instance.apps.ci.send(step)
          end # each
        end # let

        it 'should define the option' do
          expect(instance.apps.ci).
            to have_reader(:steps_with_options).
            with_value(be == expected)
        end # it
      end # describe
    end # describe

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

    describe '#cucumber' do
      let(:expected) do
        {
          :require       => 'sleeping_king_studios/tasks/ci/cucumber_task',
          :class         => 'SleepingKingStudios::Tasks::Ci::CucumberTask',
          :title         => 'Cucumber',
          :default_files => ['step_definitions', 'step_definitions.rb']
        } # end rspec
      end # let

      it 'should define the option' do
        expect(instance.ci).
          to have_reader(:cucumber).
          with_value(be == expected)
      end # it
    end # describe

    describe '#rspec' do
      let(:expected) do
        {
          :require => 'sleeping_king_studios/tasks/ci/rspec_task',
          :class   => 'SleepingKingStudios::Tasks::Ci::RSpecTask',
          :title   => 'RSpec',
          :format  => 'documentation'
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
          :require => 'sleeping_king_studios/tasks/ci/rspec_each_task',
          :class   => 'SleepingKingStudios::Tasks::Ci::RSpecEachTask',
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
          :require => 'sleeping_king_studios/tasks/ci/rubocop_task',
          :class   => 'SleepingKingStudios::Tasks::Ci::RuboCopTask',
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
          :require => 'sleeping_king_studios/tasks/ci/simplecov_task',
          :class   => 'SleepingKingStudios::Tasks::Ci::SimpleCovTask',
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
