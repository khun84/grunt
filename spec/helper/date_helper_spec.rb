require [APP_ROOT, 'spec/spec_helper'].join('/')

RSpec.describe DateHelper do
  let(:dummy_instance) do
    class DummyClass
      include DateHelper
    end
    DummyClass.new
  end

  describe '#human_readable_time' do
    subject { dummy_instance.human_readable_time(1.day.ago, Time.current)}
    it do
      expect(subject).to eq '1 day ago'
    end
  end
end
