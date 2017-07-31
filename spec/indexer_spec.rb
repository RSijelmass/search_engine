require 'indexer.rb'

describe Indexer do

  let(:indexer) {Indexer.new}
  let(:file) {double("file")}

  describe 'initializes the indexer' do
    it 'exists' do
      expect(indexer).to be_truthy
    end
  end

  describe 'processes the seedata file' do
    it 'accepts the method' do
      expect(indexer).to receive(:process_csv)
			indexer.process_csv
    end
  end
end
