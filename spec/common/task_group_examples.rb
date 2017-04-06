# spec/common/task_group_examples.rb

module Spec::Common
  # Shared contexts and examples for testing task groups.
  module TaskGroupExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    def capture_stdout
      buffer  = StringIO.new
      prior   = $stdout
      $stdout = buffer

      yield

      buffer.string
    ensure
      $stdout = prior
    end # method capture_stdout

    shared_examples 'should define task' do |definition, options = {}|
      short_name = options.fetch(:as, definition.task_name)
      task_name  = "#{options.fetch(:namespace)}:#{short_name}"

      describe "should define task #{task_name.inspect}" do
        let(:basename)      { defined?(super()) ? super() : 'rspec' }
        let(:args)          { defined?(super()) ? super() : [] }
        let(:options)       { defined?(super()) ? super() : {} }
        let(:task_name)     { task_name }
        let(:task_instance) { definition.new(options) }

        # rubocop:disable Style/GlobalVars
        def run_thor_command command, *args
          prior        = $thor_runner
          $thor_runner = true

          Thor::Runner.new.send(command, *args)
        ensure
          $thor_runner = prior
        end # method run_thor_command
        # rubocop:enable Style/GlobalVars

        it 'should add the task to `thor list`' do
          captured = capture_stdout { run_thor_command :list }

          expect(captured).to satisfy {
            captured.each_line.any? do |line|
              next false unless line.start_with? "#{basename} #{task_name}"

              desc = line.split('#')[1..-1].join('#').strip
              desc = desc[0...-3] if desc.end_with?('...')

              definition.description.start_with?(desc)
            end # any?
          } # end satisfy
        end # it

        it 'should add the full task to `thor help`' do
          captured =
            capture_stdout do
              run_thor_command :help, task_name
            end # capture

          expect(captured).to include task_name
          expect(captured).to include definition.description

          definition.options.each_key do |option|
            expect(captured).to include "--#{option}"
          end # each
        end # it

        it 'should call an instance of the task class' do
          expect(definition).
            to receive(:new).
            with(options).
            and_return(task_instance)

          expect(task_instance).
            to receive(:call).
            with(*args).
            and_return('OK')

          expect(instance.invoke task_name, args, options).
            to be == 'OK'
        end # it
      end # describe
    end # should define task
  end # module
end # module
