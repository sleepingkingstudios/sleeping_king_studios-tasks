# spec/sleeping_king_studios/tasks/file/new_spec.rb

require 'sleeping_king_studios/tasks/file/new'

RSpec.describe SleepingKingStudios::Tasks::File::New do
  let(:options)  { { 'quiet' => true } }
  let(:instance) { described_class.new options }

  describe '#call' do
    shared_examples 'should render the source file' do
      it 'should render the source file' do
        expect(instance).
          to receive(:render_template).
          with('ruby.erb', source_locals).
          and_return(rendered_source)

        instance.call file_path

        expect(File).to have_received(:write).with(file_path, rendered_source)
      end # it
    end # shared_examples

    shared_examples 'should not render the source file' do
      it 'should not render the source file' do
        begin
          instance.call file_path
        rescue RuntimeError => exception
          unless exception.message.start_with?('file already exists')
            raise exception
          end # unless
        end # begin-rescue

        expect(File).
          not_to have_received(:write).with(file_path, an_instance_of(String))
      end # it
    end # shared_examples

    shared_examples 'should render the spec file' do
      it 'should render the spec file' do
        expect(instance).
          to receive(:render_template).
          with('rspec.erb', spec_locals).
          and_return(rendered_spec)

        instance.call file_path

        expect(File).to have_received(:write).with(spec_path, rendered_spec)
      end # it
    end # shared_examples

    shared_examples 'should not render the spec file' do
      it 'should not render the spec file' do
        begin
          instance.call file_path
        rescue RuntimeError => exception
          unless exception.message.start_with?('file already exists')
            raise exception
          end # unless
        end # begin-rescue

        expect(File).
          not_to have_received(:write).with(spec_path, an_instance_of(String))
      end # it
    end # shared_examples

    let(:file_path)       { 'lib/greeter.rb' }
    let(:spec_path)       { 'spec/greeter_spec.rb' }
    let(:rendered_source) { 'class Greeter; end' }
    let(:rendered_spec)   { 'RSpec.describe Greeter do; end' }
    let(:source_locals) do
      {
        :file_path     => file_path,
        :file_name     => 'greeter',
        :relative_path => []
      } # end source locals
    end # let
    let(:spec_locals) do
      {
        :file_path     => spec_path,
        :file_name     => 'greeter_spec',
        :relative_path => []
      } # end source locals
    end # let

    before(:example) do
      allow(instance).to receive(:render_template).and_return('')

      allow(File).to receive(:write)

      allow(File).to receive(:exist?).and_return(false)

      allow(FileUtils).to receive(:mkdir_p)
    end # before example

    it { expect(instance).to respond_to(:call).with(1).argument }

    it 'should build the intermediate directories' do
      instance.call file_path

      expect(FileUtils).to have_received(:mkdir_p).with('lib')

      expect(FileUtils).to have_received(:mkdir_p).with('spec')
    end # it

    include_examples 'should render the source file'

    include_examples 'should render the spec file'

    context 'when the source file already exists' do
      before(:example) do
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end # before example

      include_examples 'should not render the source file'

      include_examples 'should not render the spec file'

      describe 'with --force' do
        let(:options) { super().merge 'force' => true }

        include_examples 'should render the source file'

        include_examples 'should render the spec file'
      end # describe
    end # context

    context 'when the spec file already exists' do
      before(:example) do
        allow(File).to receive(:exist?).with(spec_path).and_return(true)
      end # before example

      include_examples 'should not render the source file'

      include_examples 'should not render the spec file'

      describe 'with --force' do
        let(:options) { super().merge 'force' => true }

        include_examples 'should render the source file'

        include_examples 'should render the spec file'
      end # describe

      describe 'with --no-spec' do
        let(:options) { super().merge 'spec' => false }

        include_examples 'should render the source file'

        include_examples 'should not render the spec file'
      end # describe
    end # context

    describe 'with --dry-run' do
      let(:options) { super().merge 'dry-run' => true }

      it 'should not build the intermediate directories' do
        instance.call file_path

        expect(FileUtils).not_to have_received(:mkdir_p)
      end # it

      include_examples 'should not render the source file'

      include_examples 'should not render the spec file'
    end # describe

    describe 'with --no-spec' do
      let(:options) { super().merge 'spec' => false }

      it 'should build the intermediate directories' do
        instance.call file_path

        expect(FileUtils).to have_received(:mkdir_p).with('lib')

        expect(FileUtils).not_to have_received(:mkdir_p).with('spec')
      end # it

      include_examples 'should render the source file'

      include_examples 'should not render the spec file'
    end # describe

    describe 'with --prompt' do
      let(:options) { super().merge 'prompt' => true }

      context 'when the user enters "yes"' do
        before(:example) do
          expect(instance).to receive(:yes?).and_return(true)
        end # before example

        it 'should build the intermediate directories' do
          instance.call file_path

          expect(FileUtils).to have_received(:mkdir_p).with('lib')

          expect(FileUtils).to have_received(:mkdir_p).with('spec')
        end # it

        include_examples 'should render the source file'

        include_examples 'should render the spec file'
      end # context

      context 'when the user enters "no"' do
        before(:example) do
          expect(instance).to receive(:yes?).and_return(false)
        end # before example

        it 'should not build the intermediate directories' do
          instance.call file_path

          expect(FileUtils).not_to have_received(:mkdir_p)
        end # it

        include_examples 'should not render the source file'

        include_examples 'should not render the spec file'
      end # context
    end # describe
  end # describe

  describe '#render_template' do
    let(:templates_path) do
      'lib/sleeping_king_studios/tasks/file/templates'
    end # let
    let(:template) { 'Greetings, <%= name %>!' }
    let(:locals)   { { :name => 'starfighter' } }
    let(:name)     { 'ruby.erb' }
    let(:expected) { 'Greetings, starfighter!' }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:render_template)

      expect(instance).
        to respond_to(:render_template, true).
        with(1..2).arguments
    end # it

    it 'should load and render the template' do
      expect(File).
        to receive(:read).
        with(File.join templates_path, name).
        and_return(template)

      expect(instance.send :render_template, name, locals).to be == expected
    end # it
  end # describe
end # describe
