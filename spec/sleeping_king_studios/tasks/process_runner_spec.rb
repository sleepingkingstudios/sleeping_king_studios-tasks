# spec/sleeping_king_studios/tasks/process_runner_spec.rb

require 'sleeping_king_studios/tasks/process_runner'

RSpec.describe SleepingKingStudios::Tasks::ProcessRunner do
  let(:default_env)  { { :ci => true } }
  let(:default_opts) { ['--color'] }
  let(:instance) do
    described_class.new :env => default_env, :options => default_opts
  end # let

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(0).arguments.
        and_keywords(:env, :options)
    end # it
  end # describe

  describe '#default_env' do
    let(:gemfile)  { nil }
    let(:expected) { default_env }

    around(:example) do |example|
      begin
        prior                 = ENV['BUNDLE_GEMFILE']
        ENV['BUNDLE_GEMFILE'] = gemfile

        example.call
      ensure
        ENV['BUNDLE_GEMFILE'] = prior
      end # begin-ensure
    end # around example

    include_examples 'should have reader', :default_env, ->() { default_env }

    context 'when BUNDLE_GEMFILE is set' do
      let(:gemfile)  { 'path/to/gemfile' }
      let(:expected) { default_env.merge :bundle_gemfile => gemfile }

      it { expect(instance.default_env).to be == expected }
    end # context
  end # describe

  describe '#build_command' do
    shared_examples 'should build the command' do
      it 'should build the command' do
        expect(
          instance.send(
            :build_command,
            :env => env,
            :files => files,
            :options => options
          ) # end build command
        ).to be == expected
      end # it
    end # shared_examples

    let(:files)   { [] }
    let(:env)     { {} }
    let(:options) { [] }
    let(:expected) do
      expected_opts = files + default_opts + options
      expected_env  = instance.send(:default_env).merge env
      expected_env  =
        expected_env.
        map do |key, value|
          key   = tools.string.underscore(key).upcase
          value = %("#{value}") if value.is_a?(String)

          "#{key}=#{value}"
        end # map

      "#{expected_env.join ' '} : #{expected_opts.join ' '}".strip
    end # let

    def tools
      SleepingKingStudios::Tools::Toolbelt.new
    end # method tools

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_command)

      expect(instance).
        to respond_to(:build_command, true).
        with(0).arguments.
        and_keywords(:env, :files, :options)
    end # it

    include_examples 'should build the command'

    describe 'with :env => environment variables' do
      let(:env) { { :bundle_gemfile => 'path/to/Gemfile' } }

      include_examples 'should build the command'
    end # describe

    describe 'with :files => file list' do
      let(:files) { ['spec/foo', 'spec/bar', 'spec/wibble/wobble_spec.rb'] }

      include_examples 'should build the command'
    end # describe

    describe 'with :options => custom options' do
      let(:options) { ['--format=progress'] }

      include_examples 'should build the command'
    end # describe
  end # describe

  describe '#default_options' do
    include_examples 'should have reader',
      :default_options,
      ->() { default_opts }
  end # describe

  describe '#stream_process' do
    let(:io_stream) do
      StringIO.new(
        'What lies beyond the furthest reaches of the sky?'\
        "\n"\
        'That which will lead the lost child back to her mothers arms. Exile.'\
        "\n"
      ) # end stream
    end # let
    let(:command) { 'mysteria' }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:stream_process)

      expect(instance).to respond_to(:stream_process, true).with(1).argument
    end # it

    it 'should stream the output of the process' do
      buffer = ''

      allow(instance).to receive(:print) { |str| buffer << str }

      expect(IO).
        to receive(:popen).
          with(command) { |_, &block| block.call(io_stream) }

      instance.send :stream_process, command

      expect(buffer).to be == io_stream.string
    end # it
  end # describe
end # describe
