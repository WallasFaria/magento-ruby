RSpec.describe Magento::ModelMapper do
  describe '.to_hash' do
    it 'serializes object to hash' do
      class Magento::SameClass
        attr_accessor :name, :description, :items
      end

      object = Magento::SameClass.new
      object.name = 'Some name'
      object.description = 'Some description'
      object.items = [object.dup]

      expect(Magento::ModelMapper.to_hash(object)).to eql({
        'name' => 'Some name',
        'description' => 'Some description',
        'items' => [{ 'name' => 'Some name', 'description' => 'Some description' }]
      })
    end
  end

  describe '.map_hash' do
    it 'returns magento object from hash' do
      class Magento::SameClass; end
      hash = { name: 'Some name', price: 10.99 }

      object = Magento::ModelMapper.map_hash(Magento::SameClass, hash)

      expect(object).to be_instance_of(Magento::SameClass)
      expect(object.name).to eql hash[:name]
      expect(object.price).to eql hash[:price]
    end
  end

  describe '.map_array' do
    it 'returns magento object list from array of hash' do
      class Magento::SameClass; end
      array = [{ name: 'Some name', price: 10.99 }]

      object = Magento::ModelMapper.map_array('same_class', array)

      expect(object).to be_a(Array)
      expect(object).to all be_instance_of(Magento::SameClass)
    end
  end

  describe 'include ModelParser' do
    before do
      class Magento::SameClass
        include Magento::ModelParser
      end
    end

    let(:hash) { { name: 'Same name' } }

    describe '.build' do
      it 'calls Magento::ModelMapper.map_hash' do
        expect(Magento::ModelMapper).to receive(:map_hash)
          .with(Magento::SameClass, hash)

        Magento::SameClass.build(hash)
      end
    end

    describe '#to_h' do
      it 'calls Magento::ModelMapper.to_hash' do
        object = Magento::SameClass.build(hash)

        expect(Magento::ModelMapper).to receive(:to_hash).with(object)

        object.to_h
      end
    end
  end
end
