$LOAD_PATH.unshift(File.expand_path('../../libraries', __FILE__))

require 'helper'
require 'webmock/rspec'

describe Sumologic do
  let(:timeout_secs) do
    120
  end

  let(:test) do
    Sumologic.collector_exists?('pd', 'u', 'p', timeout_secs)
  end

  let(:collector_data) do
    { collectors: [{ name: :pd, id: 1 }] }
  end

  let(:auth_url) do
    'https://u:p@api.sumologic.com/api/v1'
  end

  it '#self.collector_exists?' do
    stub_request(:get, auth_url + '/collectors').to_return(body: JSON.dump(collector_data))
    expect(test).to eq(true)
  end
end

describe Sumologic::Collector do
  let(:collector) do
    Sumologic::Collector.new({ name: 'pd', api_username: 'u', api_password: 'p' })
  end

  let(:auth_url) do
    'https://u:p@api.sumologic.com/api/v1'
  end

  let(:collector_data) do
    { collectors: [{ name: :pd, id: 1 }] }
  end

  let(:source_data) do
    { sources: [{ name: :pd, name: :doit }] }
  end

  let(:timeout_secs) do
    120
  end

  it '#metadata' do
    stub_request(:get, auth_url + '/collectors').to_return(body: JSON.dump(collector_data))
    expect(collector.id).to eq(1)
    expect(collector.name).to eq('pd')
  end

  it '#sources' do
    stub_request(:get, auth_url + '/collectors').to_return(body: JSON.dump(collector_data))
    stub_request(:get, auth_url + '/collectors/1/sources').to_return(body: JSON.dump(source_data))
    expect(collector.sources.size).to eq(1)
    expect(collector.source_exist?('doit')).to eq(true)
    expect(collector.source('doit')).to_not be_nil
  end

  it '#add_source!' do
    stub_request(:get, auth_url + '/collectors').to_return(body: JSON.dump(collector_data))
    stub_request(:get, auth_url + '/collectors/1/sources').to_return(body: JSON.dump(source_data))
    stub_request(:post, auth_url + '/collectors/1/sources')
      .with(body: "{\"source\":{\"foo\":\"bar\"}}")
      .to_return(status: 200, body: '{}', headers: {})

    collector.add_source!(foo: :bar)
  end

  it '#update_source!' do
    stub_request(:get, auth_url + '/collectors').to_return(body: JSON.dump(collector_data))
    stub_request(:get, auth_url + '/collectors/1/sources').to_return(body: JSON.dump(source_data))
    stub_request(:put, auth_url + '/collectors/1/sources/2')
      .with(body: "{\"source\":{\"foo\":\"bar\",\"id\":2}}")
      .to_return(status: 200, body: '{}', headers: {})
    stub_request(:get, auth_url + '/collectors/1/sources/2')
      .to_return(status: 200, body: '{}', headers: {})

    collector.update_source!(2, { foo: :bar })
  end
end
