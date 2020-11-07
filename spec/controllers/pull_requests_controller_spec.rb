require [APP_ROOT, 'spec/spec_helper'].join('/')

RSpec.describe ::Main, :controller do
  describe 'search' do
    let(:params) { { keyword: 'khun84' } }
    before do
      allow(::EsClient).to receive_message_chain(:get_client, :search).and_return([{ 'created_at' => 1.day.ago.to_s }])
    end
    subject { JSON.parse(last_response.body) }
    it do
      get '/pull_requests/search', **params
      expect(subject).to include_json([{since: '1 day ago'}])
    end
  end
end
