RSpec.describe Magento::Invoice do
  let(:magento_client) { Magento::Request.new }

  before do
    allow(Magento::Invoice).to receive(:request).and_return(magento_client)
  end

  describe 'void' do
    let(:invoice_id) { 123 }
    let(:response) { double('Response', parse: true, status: 200) }

    describe 'class method' do
      it 'sends POST to /invoices/:id/void' do
        expect(magento_client).to receive(:post)
          .with("invoices/#{invoice_id}/void")
          .and_return(response)

        Magento::Invoice.void(invoice_id)
      end
    end

    describe 'instance method' do
      it 'calls the class method with invoice id' do
        expect(Magento::Invoice).to receive(:void).with(invoice_id)

        invoice = Magento::Invoice.build(entity_id: invoice_id)
        invoice.void
      end
    end
  end

  describe 'refund' do
    let(:invoice_id) { 123 }
    let(:response) { double('Response', parse: 1) }

    describe 'class method' do
      it 'sends POST to /invoices/:id/refund' do
        expect(magento_client).to receive(:post)
          .with("invoices/#{invoice_id}/refund", nil)
          .and_return(response)

        Magento::Invoice.refund(invoice_id)
      end
    end

    describe 'instance method' do
      it 'calls the class method with invoice id' do
        expect(Magento::Invoice).to receive(:refund).with(invoice_id, nil)

        invoice = Magento::Invoice.build(entity_id: invoice_id)
        invoice.refund
      end
    end
  end
end
