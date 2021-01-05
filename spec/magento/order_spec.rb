class RequestMock
  attr_reader :path

  def post(path)
    @path = path
    OpenStruct.new(success?: true, parse: true)
  end
end

RSpec.describe Magento::Order do
  before { Magento.url = 'https://site.com' }

  describe '.send_email' do
    it 'shuld request POST /orders/:id/emails' do
      request = RequestMock.new
      allow(Magento::Order).to receive(:request).and_return(request)

      order_id = 25
      result = Magento::Order.send_email(order_id)

      expect(request.path).to eql("orders/#{order_id}/emails")
      expect(result).to be true
    end
  end

  describe '#send_email' do
    it 'shuld request POST /orders/:id/emails' do
      request = RequestMock.new
      allow(Magento::Order).to receive(:request).and_return(request)

      order = Magento::Order.build(id: 25)
      result = order.send_email

      expect(request.path).to eql("orders/25/emails")
      expect(result).to be true
    end
  end
end
