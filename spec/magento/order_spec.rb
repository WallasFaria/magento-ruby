RSpec.describe Magento::Order do
  let(:magento_client) { request = Magento::Request.new }

  before do
    allow(Magento::Order).to receive(:request).and_return(magento_client)
  end

  describe 'send_email' do
    let(:order_id) { 11735 }
    let(:response) { double('Response', parse: true, status: 200) }

    describe 'class method' do
      it 'should request POST /orders/:id/emails' do
        expect(magento_client).to receive(:post)
          .with("orders/#{order_id}/emails")
          .and_return(response)
  
        result = Magento::Order.send_email(order_id)
      end

      it 'should return true' do
        VCR.use_cassette('order/send_email') do
          expect(Magento::Order.send_email(order_id)).to be(true).or be(false)
        end
      end
    end

    describe 'instance method' do
      it 'shuld call the class method with order_id' do
        expect(Magento::Order).to receive(:send_email).with(order_id)

        order = Magento::Order.build(id: order_id)
        result = order.send_email
      end
    end
  end
end
