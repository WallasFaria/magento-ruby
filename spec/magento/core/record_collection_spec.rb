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
    it do
      subject = create_subject_with_pagination(total_count: 60, current_page: 6, page_size: 10)
      expect(subject.last_page?).to be true
    end

    it do
      subject = create_subject_with_pagination(total_count: 60, current_page: 5, page_size: 10)
      expect(subject.last_page?).to be false
    end
  end

  describe '#next_page' do
    it 'returns next page number' do
      subject = create_subject_with_pagination(current_page: 5, total_count: 60, page_size: 10)
      expect(subject.next_page).to be 6
    end

    it 'returns nil when current page is the last' do
      subject = create_subject_with_pagination(current_page: 6, total_count: 60, page_size: 10)
      expect(subject.next_page).to be nil
    end
  end

  describe '.from_magento_response' do
    let(:response) do
      {
        'items' => [
          { 'id' => 1, 'name' => 'Product one' },
          { 'id' => 2, 'name' => 'Product two' }
        ],
        'total_count' => 12,
        'search_criteria' => { 'current_page' => 2, 'page_size' => 10 }
      }
    end

    it 'create RecordCollection instance from magento response' do
      records = Magento::RecordCollection.from_magento_response(response, model: Magento::Product)

      expect(records).to all be_a_instance_of(Magento::Product)
      expect(records.size).to eql(2)
      expect(records.total_count).to eql(12)
    end

    it 'allows specify the iterable field' do
      response['data'] = response.delete 'items'

      records = Magento::RecordCollection.from_magento_response(
        response, 
        model: Magento::Product,
        iterable_field: 'data'
      )

      expect(records.size).to eql(2)
      expect(records).to all be_a_instance_of(Magento::Product)
    end
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

  def create_subject_with_pagination(total_count:, current_page:, page_size:)
    search_criteria = double(:search_criteria, current_page: current_page, page_size: page_size)
    Magento::RecordCollection.new(items: [], total_count: total_count, search_criteria: search_criteria)
  end
end
