class Magento::Faker < Magento::Model; end

RSpec.describe Magento::Query do
  subject { Magento::Query.new(Magento::Faker) }

  describe '#where' do
    it 'add the filter to group of filters' do
      subject.where(price_gt: 50)

      expect(subject.send(:filter_groups)).to eql([
        { filters: [{ field: 'price', conditionType: 'gt', value: 50 }] }
      ])
    end

    context 'when the condition is not passed' do
      it 'the "eq" condition is used as default' do
        subject.where(price: 50)

        expect(subject.send(:filter_groups)).to eql([
          { filters: [{ field: :price, conditionType: 'eq', value: 50 }] }
        ])
      end
    end

    context 'when it is called more than once' do
      it 'adds filter in diferent groups' do
        subject.where(price_gt: 10).where(price_lt: 20)

        expect(subject.send(:filter_groups)).to eql([
          { filters: [{ field: 'price', conditionType: 'gt', value: 10 }] },
          { filters: [{ field: 'price', conditionType: 'lt', value: 20 }] }
        ])
      end
    end

    context 'when it is called with more than one filter' do
      it 'adds the filters in same group' do
        subject.where(price_gt: 10, price_lt: 20)

        expect(subject.send(:filter_groups)).to eql([
          {
            filters: [
              { field: 'price', conditionType: 'gt', value: 10 },
              { field: 'price', conditionType: 'lt', value: 20 }
            ]
          }
        ])
      end
    end

    context 'when the condition is "in" or "nin" and value is a Array' do
      it 'converts the value to string' do
        subject.where(status_in: [:pending, :new])
        subject.where(entity_id_nin: [123, 321])

        expect(subject.send(:filter_groups)).to eql([
          { filters: [{ field: 'status', conditionType: 'in', value: 'pending,new' }] },
          { filters: [{ field: 'entity_id', conditionType: 'nin', value: '123,321' }] }
        ])
      end
    end
  end

  describe '#page' do
    it do
      subject.page(2)
      expect(subject.send(:current_page)).to eql(2)
    end
  end

  describe '#page_size' do
    it do
      subject.page_size(5)
      expect(subject.instance_variable_get(:@page_size)).to eql(5)
    end
  end

  describe '#select' do
    it 'set fields inside items[]' do
      subject.select(:id, :name)

      expect(subject.send(:fields)).to eql('items[id,name],search_criteria,total_count')
    end

    it 'allow hash' do
      subject.select(:id, nested_attribute: :name)

      expect(subject.send(:fields)).to eql('items[id,nested_attribute[name]],search_criteria,total_count')
    end

    it 'allow hash with key and value as array' do
      subject.select(:id, nested_attribute: [:id, :name])

      expect(subject.send(:fields)).to eql('items[id,nested_attribute[id,name]],search_criteria,total_count')
    end

    it 'allow hash multiple level' do
      subject.select(:id, nested_attribute: [:id, :name, stock: :quantity])

      expect(subject.send(:fields)).to eql(
        'items[id,nested_attribute[id,name,stock[quantity]]],search_criteria,total_count'
      )
    end

    context 'when model is Magento::Category' do
      class Magento::Category < Magento::Model; end

      subject { Magento::Query.new(Magento::Category) }

      it 'set fields inseide children_data[]' do
        subject.select(:id, :name)

        expect(subject.send(:fields)).to eql('children_data[id,name]')
      end
    end
  end

  describe '#order' do
    it 'set order in sort_orders' do
      subject.order(name: :desc)

      expect(subject.send(:sort_orders)).to eql(
        [{ field: :name, direction: :desc }]
      )

      subject.order(created_at: :desc, name: :asc)

      expect(subject.send(:sort_orders)).to eql(
        [
          { field: :created_at, direction: :desc },
          { field: :name, direction: :asc }
        ]
      )
    end

    context 'when the direction is not passed' do
      it 'the :asc direction is used as default' do
        subject.order(:name)

        expect(subject.send(:sort_orders)).to eql(
          [{ field: :name, direction: :asc }]
        )

        subject.order(:created_at, :name)

        expect(subject.send(:sort_orders)).to eql([
          { field: :created_at, direction: :asc },
          { field: :name, direction: :asc }
        ])
      end
    end
  end

  describe '#all' do
    it 'requests the resource and returns a RecordCollection' do
      request = instance_double(Magento::Request)
      allow(subject).to receive(:request).and_return(request)
      response = double('Response', parse: {
                          'items' => [{ 'id' => 1 }],
                          'search_criteria' => { 'current_page' => 1, 'page_size' => 50 },
                          'total_count' => 1
                        })
      expect(request).to receive(:get)
        .with('fakers?searchCriteria[currentPage]=1&searchCriteria[pageSize]=50')
        .and_return(response)

      records = subject.all
      expect(records).to be_a(Magento::RecordCollection)
      expect(records.first).to be_a(Magento::Faker)
    end
  end

  describe '#first' do
    it 'returns the first record' do
      request = instance_double(Magento::Request)
      allow(subject).to receive(:request).and_return(request)
      response = double('Response', parse: {
                          'items' => [{ 'id' => 1 }],
                          'search_criteria' => { 'current_page' => 1, 'page_size' => 1 },
                          'total_count' => 1
                        })
      expect(request).to receive(:get)
        .with('fakers?searchCriteria[currentPage]=1&searchCriteria[pageSize]=1')
        .and_return(response)

      expect(subject.first).to be_a(Magento::Faker)
    end
  end

  describe '#find_by' do
    it 'builds query using where and returns first' do
      expect(subject).to receive(:where).with({ name: 'foo' }).and_return(subject)
      expect(subject).to receive(:first).and_return(:record)
      expect(subject.find_by(name: 'foo')).to eq(:record)
    end
  end

  describe '#count' do
    it 'uses select and returns total_count' do
      expect(subject).to receive(:select).with(:id).and_return(subject)
      expect(subject).to receive(:page_size).with(1).and_return(subject)
      expect(subject).to receive(:page).with(1).and_return(subject)
      expect(subject).to receive(:all).and_return(double(total_count: 5))
      expect(subject.count).to eq(5)
    end
  end

  describe '#find_each' do
    it 'loops through pages yielding records' do
      page1 = Magento::RecordCollection.new(
        items: [1, 2],
        total_count: 5,
        search_criteria: Magento::SearchCriterium.build('current_page' => 1, 'page_size' => 2)
      )
      page2 = Magento::RecordCollection.new(
        items: [3, 4],
        total_count: 5,
        search_criteria: Magento::SearchCriterium.build('current_page' => 2, 'page_size' => 2)
      )
      page3 = Magento::RecordCollection.new(
        items: [5],
        total_count: 5,
        search_criteria: Magento::SearchCriterium.build('current_page' => 3, 'page_size' => 2)
      )
      allow(subject).to receive(:all).and_return(page1, page2, page3)
      items = []
      subject.find_each { |i| items << i }
      expect(items).to eq([1, 2, 3, 4, 5])
    end

    it 'raises when model is Magento::Category' do
      query = Magento::Query.new(Magento::Category)
      expect { query.find_each { |_| } }.to raise_error(NoMethodError)
    end
  end

  describe 'private mathods' do
    describe 'endpoint' do
      it 'returns the endpoint passed in initializer' do
        q = Magento::Query.new(Magento::Faker, api_resource: 'custom')
        expect(q.send(:endpoint)).to eq('custom')
      end
    end

    describe 'verify_id' do
      it 'replaces id with primary_key when different' do
        class CustomModel < Magento::Model; end
        CustomModel.send(:primary_key=, :entity_id)
        q = Magento::Query.new(CustomModel)
        expect(q.send(:verify_id, :id)).to eq(:entity_id)
        expect(q.send(:verify_id, :name)).to eq(:name)
      end
    end

    describe 'query_params' do
      it 'returns encoded params from query state' do
        subject.where(name_like: 'John')
        subject.page(2)
        subject.page_size(10)
        subject.select(:id)
        subject.order(name: :desc)
        expected = 'searchCriteria[filterGroups][0][filters][0][field]=name&searchCriteria[filterGroups][0][filters][0][conditionType]=like&searchCriteria[filterGroups][0][filters][0][value]=John&searchCriteria[currentPage]=2&searchCriteria[sortOrders][0][field]=name&searchCriteria[sortOrders][0][direction]=desc&searchCriteria[pageSize]=10&fields=items%5Bid%5D%2Csearch_criteria%2Ctotal_count'
        expect(subject.send(:query_params)).to eq(expected)
      end
    end

    describe 'parse_filter' do
      it 'splits field and condition' do
        expect(subject.send(:parse_filter, :price_gt)).to eq(%w[price gt])
        expect(subject.send(:parse_filter, :price)).to eq([:price, 'eq'])
      end
    end

    describe 'parse_value_filter' do
      it 'joins array when condition is in or nin' do
        expect(subject.send(:parse_value_filter, 'in', [1, 2])).to eq('1,2')
        expect(subject.send(:parse_value_filter, 'eq', [1, 2])).to eq([1, 2])
      end
    end

    describe 'parse_field' do
      it 'formats nested fields' do
        expect(subject.send(:parse_field, :id, root: true)).to eq(:id)
        expect(subject.send(:parse_field, { nested: :name })).to eq('nested[name]')
        expect(subject.send(:parse_field, { nested: [:id, :name] })).to eq('nested[id,name]')
      end
    end

    describe 'encode' do
      it 'encodes hash params' do
        expected = 'a[b][c]=1&a[b][d]=2&arr[0]=1&arr[1]=2'
        result = subject.send(:encode, a: { b: { c: 1, d: 2 } }, arr: [1, 2])
        expect(result).to eq(expected)
      end
    end

    describe 'append_key' do
      it do
        expect(subject.send(:append_key, nil, 'key')).to eq('key')
        expect(subject.send(:append_key, 'root', 'key')).to eq('root[key]')
      end
    end
  end
end
