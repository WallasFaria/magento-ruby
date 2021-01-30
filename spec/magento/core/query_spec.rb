class Magento::Faker < Magento::Model; end

RSpec.describe Magento::Query do
  subject { Magento::Query.new(Magento::Faker) }

  describe '#where' do
    it 'is pending'
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
