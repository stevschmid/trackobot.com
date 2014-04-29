require 'spec_helper'

describe 'Registrations' do
  let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }

  it 'creates an account automatically' do
    post '/users', format: :json
    expect(response.code).to eq('200')
  end

  it 'returns the generated user name and password' do
    post '/users', format: :json
    expect(parsed_response[:username]).to be_present
    expect(parsed_response[:password]).to be_present
  end

  describe 'spam' do
    it 'blocks after three sign ups in one hour' do
      3.times { post '/users', format: :json }
      post '/users', format: :json
      expect(response.code).to eq('429')
    end
  end
end
