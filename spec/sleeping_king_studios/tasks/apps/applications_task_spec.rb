# spec/sleeping_king_studios/tasks/apps/applications_task_spec.rb

require 'sleeping_king_studios/tasks/apps/applications_task'

RSpec.describe SleepingKingStudios::Tasks::Apps::ApplicationsTask do
  let(:described_class) do
    Class.new(SleepingKingStudios::Tasks::Task) do
      include SleepingKingStudios::Tasks::Apps::ApplicationsTask
    end # class
  end # let
  let(:options)  { {} }
  let(:instance) { described_class.new(options) }

  it { expect(described_class).to be < SleepingKingStudios::Tasks::Task }

  describe '#applications' do
    let(:expected) { SleepingKingStudios::Tasks::Apps.configuration }

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:applications)

      expect(instance).to respond_to(:applications, true).with(0).arguments
    end # it

    it { expect(instance.send(:applications)).to be == expected }
  end # describe

  describe '#filter_applications' do
    let(:applications) do
      {
        'admin'   => {},
        'public'  => {},
        'reports' => {}
      } # end applications
    end # let
    let(:config) do
      applications.each.with_object({}) do |(name, data), hsh|
        hsh[name] = SleepingKingStudios::Tasks::Apps::AppConfiguration.new(data)
      end # each
    end # let
    let(:expected) { config }

    before(:example) do
      allow(instance).to receive(:applications).and_return(config)
    end # before example

    it 'should define the private method' do
      expect(instance).not_to respond_to(:filter_applications)

      expect(instance).
        to respond_to(:filter_applications, true).
        with(0).arguments.
        and_keywords(:only)
    end # it

    it 'should filter the applications' do
      expect(instance.send :filter_applications, :only => []).to be == expected
    end # it

    describe 'with :only => applications' do
      let(:only) { %w[admin reports] }
      let(:expected) do
        {
          'admin'   => config['admin'],
          'reports' => config['reports']
        } # end applications
      end # let

      it 'should filter the applications' do
        expect(instance.send :filter_applications, :only => only).
          to be == expected
      end # it
    end # describe
  end # describe
end # describe
