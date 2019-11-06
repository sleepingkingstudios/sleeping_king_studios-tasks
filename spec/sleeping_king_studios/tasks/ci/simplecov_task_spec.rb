# spec/sleeping_king_studios/tasks/ci/simplecov_task_spec.rb

require 'sleeping_king_studios/tasks/ci/simplecov_task'

RSpec.describe SleepingKingStudios::Tasks::Ci::SimpleCovTask do
  let(:instance) { described_class.new({}) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::description' do
    let(:expected) { 'Aggregates the SimpleCov results.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'simplecov'
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should wrap the SimpleCov results' do
      it 'should wrap the SimpleCov results' do
        expect(SimpleCov).to receive(:result).and_return(expected)

        results = instance.call

        expect(results).to be_a expected_class

        %i[covered_percent covered_lines missed_lines total_lines].
          each do |method|
            expect(results.send method).to be == expected.send(method)
          end # each
      end # it
    end # shared_examples

    let(:expected_class) { SleepingKingStudios::Tasks::Ci::SimpleCovResults }
    let(:expected) do
      double(
        'results',
        :covered_percent => 97.0,
        :covered_lines   => 97,
        :missed_lines    => 3,
        :total_lines     => 100
      ) # end results
    end # let

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should wrap the SimpleCov results'
  end # describe
end # describe
