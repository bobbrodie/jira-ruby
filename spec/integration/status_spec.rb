require 'spec_helper'

describe JIRA::Resource::Status do
  with_each_client do |site_url, client|
    let(:client) { client }
    let(:site_url) { site_url }

    let(:key) { '1' }

    let(:expected_attributes) do
      JSON.parse(File.read('spec/mock_responses/status/1.json'))
    end

    let(:expected_collection_length) { 5 }

    it_should_behave_like 'a resource'
    it_should_behave_like 'a resource with a collection GET endpoint'
    it_should_behave_like 'a resource with a singular GET endpoint'
  end
end
