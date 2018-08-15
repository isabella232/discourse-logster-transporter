require 'rails_helper'

RSpec.describe DiscourseLogsterTransporter::Store do
  let(:root_url) { 'https://test.somesite.org' }
  let(:store) { described_class.new(root_url: root_url, key: '') }

  describe '#report' do
    before do
      @store_level = Logster.store.level
      Logster.store.level = 2
    end

    after do
      Logster.store.level = @store_level
    end

    it 'should add the right message into the buffer' do
      store.report(2, 'test', 'test', { test: 'testing' })
      store.report(3, 'test2', 'test2')
      store.report(1, 'test2', 'test2')

      expect(store.buffer.length).to eq(2)

      first_log = store.buffer.first

      expect(first_log[:severity]).to eq(2)
      expect(first_log[:message]).to eq('test')
      expect(first_log[:progname]).to eq('test')
      expect(first_log[:opts][:test]).to eq('testing')
      expect(first_log[:opts][:backtrace]).to be_present

      second_log = store.buffer.last

      expect(second_log[:opts].keys).to contain_exactly(:backtrace, :env)

      expect(second_log[:opts][:env].keys).to contain_exactly(
        "application_version", "process_id", "hostname"
      )
    end
  end
end