# spec/sleeping_king_studios/tasks_spec.rb

require 'sleeping_king_studios/tasks'

RSpec.describe SleepingKingStudios::Tasks do
  describe '::configuration' do
    it 'should define the class reader' do
      expect(described_class).
        to have_reader(:configuration).
        with_value(be_a SleepingKingStudios::Tasks::Configuration)
    end # it
  end # describe

  describe '::gem_path' do
    let(:root_path) { __dir__.sub %r{/spec/sleeping_king_studios\z}, '' }

    it 'should define the class reader' do
      expect(described_class).to have_reader(:gem_path).with_value(root_path)
    end # it
  end # describe
end # describe
