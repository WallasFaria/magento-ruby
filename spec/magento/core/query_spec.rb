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
    it 'is pending'
  end

  describe '#all' do
    it 'is pending'
  end

  describe '#first' do
    it 'is pending'
  end

  describe '#find_by' do
    it 'is pending'
  end

  describe '#count' do
    it 'is pending'
  end

  describe '#find_each' do
    it 'is pending'
  end

  describe 'private mathods' do
    describe 'endpoint' do
      it 'is pending'
    end

    describe 'verify_id' do
      it 'is pending'
    end

    describe 'query_params' do
      it 'is pending'
    end

    describe 'parse_filter' do
      it 'is pending'
    end

    describe 'parse_value_filter' do
      it 'is pending'
    end

    describe 'parse_field' do
      it 'is pending'
    end

    describe 'encode' do
      it 'is pending'
    end

    describe 'append_key' do
      it 'is pending'
    end
  end
end
