# spec/sleeping_king_studios/tasks/ci/results_helpers_spec.rb

require 'sleeping_king_studios/tasks/ci/results_helpers'

RSpec.describe SleepingKingStudios::Tasks::Ci::ResultsHelpers do
  let(:described_class) do
    Class.new do
      include SleepingKingStudios::Tasks::Ci::ResultsHelpers
    end # class
  end # let
  let(:instance) { described_class.new }

  describe '#results_color' do
    let(:results) do
      double(
        'results',
        :failing? => false,
        :pending? => false,
        :empty?   => false
      ) # end results
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:results_color)

      expect(instance).to respond_to(:results_color, true).with(1).argument
    end # it

    it { expect(instance.send :results_color, results).to be :green }

    describe 'with empty results' do
      before(:example) { allow(results).to receive(:empty?).and_return(true) }

      it { expect(instance.send :results_color, results).to be :yellow }
    end # it

    describe 'with failing results' do
      before(:example) { allow(results).to receive(:failing?).and_return(true) }

      it { expect(instance.send :results_color, results).to be :red }
    end # it

    describe 'with pending results' do
      before(:example) { allow(results).to receive(:pending?).and_return(true) }

      it { expect(instance.send :results_color, results).to be :yellow }
    end # it

    describe 'with results that respond to :errored?' do
      let(:results) do
        double(
          'results',
          :errored? => false,
          :failing? => false,
          :pending? => false,
          :empty?   => false
        ) # end results
      end # let

      it { expect(instance.send :results_color, results).to be :green }

      describe 'with errored results' do
        before(:example) do
          allow(results).to receive(:errored?).and_return(true)
        end # before example

        it { expect(instance.send :results_color, results).to be :red }
      end # it
    end # it
  end # describe

  describe '#results_state' do
    let(:results) do
      double(
        'results',
        :failing? => false,
        :pending? => false,
        :empty?   => false
      ) # end results
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:results_state)

      expect(instance).to respond_to(:results_state, true).with(1).argument
    end # it

    it { expect(instance.send :results_state, results).to be == 'Passing' }

    describe 'with empty results' do
      before(:example) { allow(results).to receive(:empty?).and_return(true) }

      it { expect(instance.send :results_state, results).to be == 'Pending' }
    end # it

    describe 'with failing results' do
      before(:example) { allow(results).to receive(:failing?).and_return(true) }

      it { expect(instance.send :results_state, results).to be == 'Failing' }
    end # it

    describe 'with pending results' do
      before(:example) { allow(results).to receive(:pending?).and_return(true) }

      it { expect(instance.send :results_state, results).to be == 'Pending' }
    end # it

    describe 'with results that respond to :errored?' do
      let(:results) do
        double(
          'results',
          :errored? => false,
          :failing? => false,
          :pending? => false,
          :empty?   => false
        ) # end results
      end # let

      it { expect(instance.send :results_state, results).to be == 'Passing' }

      describe 'with errored results' do
        before(:example) do
          allow(results).to receive(:errored?).and_return(true)
        end # before example

        it { expect(instance.send :results_state, results).to be == 'Errored' }
      end # it
    end # it
  end # describe
end # describe
