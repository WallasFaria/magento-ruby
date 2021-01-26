RSpec.describe Magento::Product do
  let(:magento_client) { Magento::Request.new }

  before { allow(Magento::Product).to receive(:request).and_return(magento_client) }

  describe '.find' do
    it 'request to /prducts/:sku' do
      response = double('HTTP::Response', parse: {})

      expect(magento_client).to receive(:get).with('products/1243').and_return(response)

      Magento::Product.find('1243')
    end

    it 'returns a Magento::Product instance' do
      VCR.use_cassette('product/find') do
        product = Magento::Product.find('1243')
        expect(product).to be_an_instance_of(Magento::Product)
      end
    end
  end

  describe '#set_custom_attribute' do
    let(:product) { Magento::Product.build(
      sku: 25,
      custom_attributes: [
        { attribute_code: 'description', value: 'Some description' }
      ]
    ) }

    context 'when the custom attribute already exists' do
      it 'must change the attribute value' do
        expect(product.description).to eql('Some description')
        product.set_custom_attribute(:description, 'description updated')
        expect(product.attr(:description)).to eql('description updated')
      end
    end

    context 'when the custom attribute does not exists' do
      it 'must add a new attribute' do
        expect(product.attr(:new_attribute)).to be_nil
        expect(product.attr(:other_new_attribute)).to be_nil

        product.set_custom_attribute(:new_attribute, 'value')
        product.set_custom_attribute('other_new_attribute', [1, 2])

        expect(product.attr(:new_attribute)).to eql('value')
        expect(product.attr(:other_new_attribute)).to eql([1, 2])
      end
    end
  end
end
