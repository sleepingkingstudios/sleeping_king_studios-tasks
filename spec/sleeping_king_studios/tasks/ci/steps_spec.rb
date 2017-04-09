# spec/sleeping_king_studios/tasks/ci/steps_spec.rb

require 'sleeping_king_studios/tasks/ci/steps'

RSpec.describe SleepingKingStudios::Tasks::Ci::Steps do
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs the configured steps for your test suite.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value 'steps'
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should report on the results of each step' do
      it 'should report on the results of each step' do
        captured, _ = capture_task

        expected_steps.each do |name, config|
          expect(captured.each_line).to satisfy { |enum|
            enum.any? do |line|
              line.include?(name) && line.include?(config[:results].to_s)
            end # any?
          } # end satisfy
        end # each
      end # it
    end # shared_examples

    shared_examples 'should report on the failing steps' do
      it 'should report on the failing steps' do
        captured, raised = capture_task

        expect(captured.each_line).to satisfy { |enum|
          enum.any? do |line|
            line.include?('The following steps failed:') &&
              failing_steps.all? { |step| line.include?(step) }
          end # any?
        } # end satisfy

        expect(raised).to be_a Thor::Error
        expect(raised.message).to be == 'The CI suite failed.'
      end # it
    end # shared_examples

    let(:rspec_results) do
      SleepingKingStudios::Tasks::Ci::RSpecResults.new(
        'duration'      => 1.0,
        'example_count' => 6,
        'failure_count' => 1,
        'pending_count' => 2
      ) # end rspec results
    end # let
    let(:rubocop_results) do
      SleepingKingStudios::Tasks::Ci::RuboCopResults.new(
        'inspected_file_count' => 1.0,
        'offense_count'        => 3
      ) # end rubocop results
    end # let
    let(:expected_files)   { [] }
    let(:expected_options) { [] }
    let(:expected_steps) do
      {
        'RSpec' => {
          :class   => SleepingKingStudios::Tasks::Ci::RSpec,
          :results => rspec_results
        }, # end rspec
        'RuboCop' => {
          :class   => SleepingKingStudios::Tasks::Ci::RuboCop,
          :results => rubocop_results
        } # end rubocop
      } # end steps
    end # let
    let(:failing_steps) do
      expected_steps.
        select { |_, hsh| hsh[:results].failing? }.
        map { |key, _| key }
    end # let

    def capture_stdout
      buffer  = StringIO.new
      prior   = $stdout
      $stdout = buffer

      yield

      buffer.string
    ensure
      $stdout = prior
    end # method capture_stdout

    def capture_task
      raised   = nil
      captured =
        capture_stdout do
          begin
            instance.call(expected_files)
          rescue Thor::Error => exception
            raised = exception
          end # begin-rescue
        end # capture

      [captured, raised]
    end # method capture_task

    before(:example) do
      expected_steps.each_value do |config|
        instance = config[:class].new(options)

        expect(config[:class]).
          to receive(:new).
          with(options).
          and_return(instance)

        expect(instance).
          to receive(:call).
          with(expected_files).
          and_return(config[:results])
      end # each
    end # before example

    include_examples 'should report on the results of each step'

    describe 'with files' do
      let(:expected_files) do
        ['spec/foo', 'spec/bar', 'spec/wibble/wobble_spec.rb']
      end # let

      include_examples 'should report on the results of each step'
    end # describe

    context 'with no failing steps' do
      before(:example) do
        expected_steps.each_value do |hsh|
          allow(hsh[:results]).to receive(:failing?).and_return(false)
        end # expected_steps
      end # before example

      it 'should report no failing steps' do
        captured = capture_stdout { instance.call(expected_files) }

        expect(captured).not_to match 'The following steps failed:'
      end # it
    end # context

    context 'with one failing step' do
      before(:example) do
        expected_steps.each_value.with_index do |hsh, index|
          allow(hsh[:results]).to receive(:failing?).and_return(index.zero?)
        end # expected_steps
      end # before example

      include_examples 'should report on the failing steps'
    end # context

    context 'with many failing steps' do
      before(:example) do
        expected_steps.each_value do |hsh|
          allow(hsh[:results]).to receive(:failing?).and_return(true)
        end # expected_steps
      end # before example

      include_examples 'should report on the failing steps'
    end # context

    context 'with many pending steps' do
      before(:example) do
        expected_steps.each_value do |hsh|
          allow(hsh[:results]).to receive(:failing?).and_return(false)

          allow(hsh[:results]).to receive(:pending?).and_return(true)
        end # expected_steps
      end # before example

      it 'should report no failing steps' do
        captured = capture_stdout { instance.call(expected_files) }

        expect(captured).not_to match 'The following steps failed:'
      end # it
    end # context
  end # describe
end # describe
