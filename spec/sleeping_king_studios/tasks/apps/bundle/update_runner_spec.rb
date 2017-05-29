# spec/sleeping_king_studios/tasks/apps/bundle/update_runner_spec.rb

require 'sleeping_king_studios/tasks/apps/bundle/update_runner'

RSpec.describe SleepingKingStudios::Tasks::Apps::Bundle::UpdateRunner do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#call' do
    let(:gemfile) { 'path/to/gemfile' }
    let(:command) { %(BUNDLE_GEMFILE="#{gemfile}" bundle update) }

    it { expect(instance).to respond_to(:call).with(1).argument }

    it 'should call a bundler process' do
      expect(instance).to receive(:stream_process).with(command)

      instance.call gemfile
    end # it
  end # describe
end # describe
