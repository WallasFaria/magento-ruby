RSpec.describe Magento::RecordCollection do
  subject { Magento::RecordCollection.new(items: []) }

  describe 'read only attributes' do
    it { is_expected.to respond_to(:items) }
    it { is_expected.to respond_to(:search_criteria) }
    it { is_expected.to respond_to(:total_count) }
    it { is_expected.not_to respond_to(:items=) }
    it { is_expected.not_to respond_to(:search_criteria=) }
    it { is_expected.not_to respond_to(:total_count=) }
  end

  describe '#last_page?' do
    it 'is pending'
  end

  describe '#next_page' do
    it 'is pending'
  end

  describe '.from_magento_response' do
    it 'is pending'
  end

  describe 'delegated methods' do
    let(:methods) do
      %i[
        count
        length
        size
        first
        last
        []
        find
        each
        each_with_index
        sample
        map
        select
        filter
        reject
        collect
        take
        take_while
        sort
        sort_by
        reverse_each
        reverse
        all?
        any?
        none?
        one?
        empty?
      ]
    end

    it 'from #items' do
      methods.each do |method|
        expect(subject).to respond_to(method)
        expect(subject.items).to receive(method)
        subject.send(method)
      end
    end
  end
end
