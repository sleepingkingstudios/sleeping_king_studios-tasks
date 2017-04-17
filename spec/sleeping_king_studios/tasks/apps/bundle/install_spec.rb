# spec/sleeping_king_studios/tasks/apps/bundle/install_spec.rb

require 'sleeping_king_studios/tasks/apps/bundle/install'

RSpec.describe SleepingKingStudios::Tasks::Apps::Bundle::Install do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) do
      'Installs the Ruby gem dependencies for each application.'
    end # let

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'install'
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should call an install runner' do
      it 'should call an install runner' do
        allow(SleepingKingStudios::Tasks::Apps::Bundle::InstallRunner).
          to receive(:new).
          with(no_args).
          and_return(runner)

        gemfiles.each do |gemfile|
          expect(runner).to receive(:call).with(gemfile)
        end # each

        instance.call(*applications)
      end # it
    end # shared_examples

    let(:applications) { [] }
    let(:gemfiles) do
      ['Gemfile', 'path/to/gemfile', 'path/to/other/Gemfile']
    end # let
    let(:runner) do
      SleepingKingStudios::Tasks::Apps::Bundle::InstallRunner.new
    end # let

    before(:example) do
      allow(instance).
        to receive(:gemfiles).
        with(applications).
        and_return(gemfiles)

      instance.mute!
    end # before example

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call an install runner'

    describe 'with applications' do
      let(:applications) { %w(public) }

      include_examples 'should call an install runner'
    end # describe
  end # describe

  describe '#gemfiles' do
    let(:applications) do
      {
        'admin'   => {},
        'public'  =>
          {
            'gemfile' => 'path/to/gemfile'
          }, # end public
        'reports' => {}
      } # end applications
    end # let
    let(:only)     { [] }
    let(:expected) { ['Gemfile', 'path/to/gemfile'] }

    before(:example) do
      allow(instance).to receive(:applications).and_return(applications)
    end # before example

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:gemfiles)

      expect(instance).to respond_to(:gemfiles, true).with(1).arguments
    end # it

    it { expect(instance.send :gemfiles, only).to be == expected }

    describe 'with filtered applications' do
      let(:only)     { %w(public) }
      let(:expected) { ['path/to/gemfile'] }

      it { expect(instance.send :gemfiles, only).to be == expected }
    end # describe
  end # describe
end # describe
