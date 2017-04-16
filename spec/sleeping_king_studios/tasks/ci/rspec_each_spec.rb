# spec/sleeping_king_studios/tasks/ci/rspec_each_spec.rb

require 'sleeping_king_studios/tasks/ci/rspec_each'

RSpec.describe SleepingKingStudios::Tasks::Ci::RSpecEach do
  let(:options)  { { :quiet => true } }
  let(:instance) { described_class.new(options) }

  describe '::description' do
    let(:expected) { 'Runs each spec file as an individual RSpec process.' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:description).with_value expected
    end # it
  end # describe

  describe '::task_name' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:task_name).with_value :rspec_each
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should run each RSpec file' do
      describe 'should run each RSpec file' do
        before(:example) do
          allow(Time).to receive(:now).and_return(Time.at(0), Time.at(3))

          allow(SleepingKingStudios::Tasks::Ci::RSpecRunner).
            to receive(:new).
            with(:env => expected_env).
            and_return(runner)

          expect(instance).
            to receive(:files_list).
            with(expected_groups).
            and_return(expected_files)

          expected_files.each.with_index do |expected_file, index|
            expect(runner).
              to receive(:call).
              with(:files => [expected_file]).
              and_return(expected_results[index])
          end # each
        end # before example

        it 'should report on the results of each step' do
          captured = capture_stdout { instance.call(*expected_groups) }

          expected_files.each.with_index do |file, index|
            results = expected_results[index]
            badge   =
              if !results['failure_count'].zero?
                'Failure'
              elsif !results['pending_count'].zero?
                'Pending'
              else
                'Success'
              end # if-elsif-else

            expect(captured.each_line).to satisfy { |enum|
              enum.any? do |line|
                line.include?(file) && line.include?(badge)
              end # any?
            } # end satisfy
          end # each
        end # it

        it 'should return the aggregate results' do
          results  = nil
          captured =
            capture_stdout { results = instance.call(*expected_groups) }

          expect(results).to be_a expected_class
          expect(results).to be == expected

          expect(captured).to include(results.to_s)
        end # it
      end # describe
    end # shared_examples

    let(:expected_groups) { [] }
    let(:expected_files) do
      [
        'spec/sleeping_king_studios/tasks/ci/rspec_spec.rb',
        'spec/sleeping_king_studios/tasks/ci/rubocop_spec.rb',
        'spec/sleeping_king_studios/tasks/ci/simplecov_spec.rb'
      ] # end files
    end # let
    let(:expected_results) do
      [
        build_results(1),
        build_results(2),
        build_results(3)
      ] # end results
    end # let
    let(:expected_env)    { { :coverage => false } }
    let(:expected_class)  { SleepingKingStudios::Tasks::Ci::RSpecEachResults }
    let(:expected) do
      hsh = {
        'failing_files' => [],
        'pending_files' => [],
        'file_count'    => 0,
        'duration'      => 3.0
      } # end hash

      expected_files.each.with_index do |file, index|
        hsh['file_count'] += 1

        result = expected_results[index]

        if !result['failure_count'].zero?
          hsh['failing_files'] << file
        elsif !result['pending_count'].zero?
          hsh['pending_files'] << file
        end # if-elsif
      end # result

      hsh
    end # let
    let(:runner) do
      SleepingKingStudios::Tasks::Ci::RSpecRunner.new(:env => expected_env)
    end # let

    def build_results examples, pending: 0, failing: 0
      {
        'duration'      => 1.0,
        'example_count' => examples,
        'failure_count' => failing,
        'pending_count' => pending
      } # end expected
    end # method build_results

    def capture_stdout
      buffer  = StringIO.new
      prior   = $stdout
      $stdout = buffer

      yield

      buffer.string
    ensure
      $stdout = prior
    end # method capture_stdout

    include_examples 'should run each RSpec file'

    context 'when a file has pending results' do
      let(:expected_results) do
        results = super()

        results[1] = build_results(2, :pending => 1)

        results
      end # let

      include_examples 'should run each RSpec file'
    end # context

    context 'when a file has failing results' do
      let(:expected_results) do
        results = super()

        results[1] = build_results(2, :failing => 1)

        results
      end # let

      include_examples 'should run each RSpec file'
    end # context

    describe 'with files' do
      let(:expected_groups) { ['spec/sleeping_king_studios/tasks/ci'] }

      include_examples 'should run each RSpec file'
    end # describe
  end # describe

  describe '#files_list' do
    let(:groups) { [] }
    let(:expected) do
      Dir['spec/**/*_spec.rb']
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:files_list)

      expect(instance).to respond_to(:files_list, true).with(1).argument
    end # it

    it 'should return the list of files' do
      expect(instance.send :files_list, groups).to be == expected
    end # it

    describe 'with a list of files' do
      let(:groups) do
        [
          'spec/sleeping_king_studios/tasks/ci/rspec_spec.rb',
          'spec/sleeping_king_studios/tasks/ci/rubocop_spec.rb',
          'spec/sleeping_king_studios/tasks/ci/simplecov_spec.rb'
        ] # end groups
      end # let
      let(:expected) { groups }

      it 'should return the list of files' do
        expect(instance.send :files_list, groups).to be == expected
      end # it
    end # describe

    describe 'with a directory' do
      let(:groups) { ['spec/sleeping_king_studios/tasks/ci'] }
      let(:expected) do
        super().select { |str| str.start_with?(groups.first) }
      end # let

      it 'should return the list of files' do
        expect(instance.send :files_list, groups).to be == expected
      end # it
    end # describe
  end # describe
end # describe
