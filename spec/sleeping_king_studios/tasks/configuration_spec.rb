# spec/sleeping_king_studios/tasks/configuration_spec.rb

require 'sleeping_king_studios/tasks/configuration'

RSpec.describe SleepingKingStudios::Tasks::Configuration do
  let(:data)         { {} }
  let(:config_class) { SleepingKingStudios::Tools::Toolbox::Configuration }
  let(:instance)     { described_class.new(data) }

  describe '#file' do
    it 'should define the namespace' do
      expect(instance).
        to have_reader(:file).
        with_value(be_a config_class)
    end # it

    describe '::default_template_path' do
      let(:expected) do
        File.join(
          SleepingKingStudios::Tasks.gem_path,
          'file',
          'templates'
        ) # end join
      end # let

      it 'should define the class method' do
        expect(instance.file.class).
          to have_reader(:default_template_path).
          with_value(be == expected)
      end # it
    end # describe

    describe '#template_paths' do
      let(:expected) do
        [
          File.join(
            SleepingKingStudios::Tasks.gem_path,
            'file',
            'templates'
          ) # end join
        ] # end array
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
