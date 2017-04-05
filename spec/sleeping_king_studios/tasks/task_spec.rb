# spec/sleeping_king_studios/tasks/task_spec.rb

require 'sleeping_king_studios/tasks'

RSpec.describe SleepingKingStudios::Tasks::Task do
  let(:described_class) { Class.new(super()) }
  let(:options)         { { :silliness => 11 } }
  let(:instance)        { described_class.new options }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::description' do
    it 'should define the class reader' do
      expect(described_class).
        to have_reader(:description).
        with_value(an_instance_of String)
    end # it
  end # describe

  describe '::option' do
    let(:option_name)   { :silliness }
    let(:option_params) { { :type => :numeric } }

    it 'should define the class method' do
      expect(described_class).to respond_to(:option).with(2).arguments
    end # it

    it 'should update the options' do
      expect { described_class.option option_name, option_params }.
        to change(described_class, :options).
        to include(option_name => option_params)
    end # it
  end # describe

  describe '::options' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:options).with_value({})
    end # it
  end # describe

  describe '::task_name' do
    let(:class_name) { 'Ministry::Silly::Walks' }

    before(:example) do
      allow(described_class).to receive(:name).and_return(class_name)
    end # before example

    it 'should define the class reader' do
      expect(described_class).
        to have_reader(:task_name).
        with_value('walks')
    end # it
  end # describe

  describe '#call' do
    it { expect(instance).to respond_to(:call).with_unlimited_arguments }
  end # method describe

  describe '#options' do
    include_examples 'should have reader', :options, ->() { be == options }
  end # describe
end # describe
