# spec/sleeping_king_studios/tasks/apps/bundle/install_spec.rb

require 'sleeping_king_studios/tasks/apps/bundle/install'

RSpec.describe SleepingKingStudios::Tasks::Apps::Bundle::Install do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }
  let(:applications) do
    {
      'admin'   => {},
      'public'  => {},
      'reports' => {}
    } # end applications
  end # let
  let(:config) do
    applications.each.with_object({}) do |(name, data), hsh|
      tools = SleepingKingStudios::Tools::Toolbelt.instance
      data  = tools.hash.convert_keys_to_symbols(data)

      hsh[name] = SleepingKingStudios::Tasks::Apps::AppConfiguration.new(data)
    end # each
  end # let

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

        instance.call(*only)
      end # it
    end # shared_examples

    let(:only) { [] }
    let(:gemfiles) do
      ['Gemfile', 'path/to/gemfile', 'path/to/other/Gemfile']
    end # let
    let(:runner) do
      SleepingKingStudios::Tasks::Apps::Bundle::InstallRunner.new
    end # let

    before(:example) do
      allow(instance).
        to receive(:filter_applications).
        with(:only => only).
        and_return(config)

      allow(instance).
        to receive(:gemfiles).
        with(config).
        and_return(gemfiles)

      instance.mute!
    end # before example

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should call an install runner'

    describe 'with applications' do
      let(:only) { %w(public) }

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
    let(:expected) { ['Gemfile', 'path/to/gemfile'] }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:gemfiles)

      expect(instance).to respond_to(:gemfiles, true).with(1).arguments
    end # it

    it { expect(instance.send :gemfiles, config).to be == expected }
  end # describe
end # describe
