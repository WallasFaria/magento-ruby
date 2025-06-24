RSpec.describe Magento::Cart do
  let(:magento_client) { Magento::Request.new }

  before do
    allow(Magento::Cart).to receive(:request).and_return(magento_client)
  end

  describe '.order' do
    it 'accepts string keyed attributes' do
      attributes = {
        'cartId' => '123',
        'paymentMethod' => { method: 'cashondelivery' },
        'email' => 'customer@example.com'
      }
      response = double('Response', parse: 'order_id', status: 200)

      expect(magento_client).to receive(:put)
        .with('carts/123/order', {
          cartId: '123',
          paymentMethod: { method: 'cashondelivery' },
          email: 'customer@example.com'
        })
        .and_return(response)

      expect(Magento::Cart.order(attributes)).to eql('order_id')
    end
  end
end

RSpec.describe Magento::GuestCart do
  let(:magento_client) { Magento::Request.new }

  before do
    allow(Magento::GuestCart).to receive(:request).and_return(magento_client)
  end

  describe '.payment_information' do
    it 'accepts string keyed attributes' do
      attributes = {
        'cartId' => 'abc123',
        'paymentMethod' => { method: 'checkmo' },
        'email' => 'guest@example.com'
      }
      response = double('Response', parse: 'order_id', status: 200)

      expect(magento_client).to receive(:post)
        .with('guest-carts/abc123/payment-information', {
          cartId: 'abc123',
          paymentMethod: { method: 'checkmo' },
          email: 'guest@example.com'
        })
        .and_return(response)

      expect(Magento::GuestCart.payment_information(attributes)).to eql('order_id')
    end
  end
end
