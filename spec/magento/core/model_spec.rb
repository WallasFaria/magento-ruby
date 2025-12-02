RSpec.describe Magento::Model do
  class TestModel < Magento::Model
    attr_accessor :id, :name
  end

  let(:magento_client) { instance_double(Magento::Request) }

  before { allow(TestModel).to receive(:request).and_return(magento_client) }

  describe 'public method' do
    describe '.find' do
      it 'requests record and builds model' do
        response = double('Response', parse: { id: 1 })
        expect(magento_client).to receive(:get).with('test_models/1').and_return(response)

        record = TestModel.find(1)
        expect(record).to be_a(TestModel)
        expect(record.id).to eq(1)
      end
    end

    describe '.create' do
      it 'sends POST request with entity key' do
        response = double('Response', parse: { id: 2, name: 'test' })
        expect(magento_client).to receive(:post)
          .with('test_models', { 'test_model' => { name: 'test' } })
          .and_return(response)

        record = TestModel.create(name: 'test')
        expect(record).to be_a(TestModel)
        expect(record.id).to eq(2)
      end
    end

    describe '.update' do
      it 'sends PUT request and builds record' do
        response = double('Response', parse: { id: 2, name: 'updated' })
        expect(magento_client).to receive(:put)
          .with('test_models/2', { 'test_model' => { name: 'updated' } })
          .and_return(response)

        record = TestModel.update(2, name: 'updated')
        expect(record).to be_a(TestModel)
        expect(record.name).to eq('updated')
      end
    end

    describe '.delete' do
      it 'sends DELETE request' do
        response = double('Response', status: double(success?: true))
        expect(magento_client).to receive(:delete)
          .with('test_models/2')
          .and_return(response)

        expect(TestModel.delete(2)).to be true
      end
    end

    describe '#save' do
      it 'calls the update class method' do
        model = TestModel.new
        model.id = 5
        allow(model).to receive(:to_h).and_return(name: 'saved')
        expect(TestModel).to receive(:update)
          .with(5, { name: 'saved' })
          .and_yield({})

        model.save
      end
    end

    describe '#update' do
      it 'calls the update class method' do
        model = TestModel.new
        model.id = 8
        expect(TestModel).to receive(:update)
          .with(8, { name: 'upd' })
          .and_yield({})

        model.update(name: 'upd')
      end
    end

    describe '#delete' do
      it 'calls the delete class method' do
        model = TestModel.new
        model.id = 9
        expect(TestModel).to receive(:delete).with(9)
        model.delete
      end
    end

    describe '.api_resource' do
      it 'returns pluralized entity name by default' do
        expect(TestModel.api_resource).to eq('test_models')
      end

      it 'uses custom endpoint when set' do
        TestModel.send(:endpoint=, 'custom_endpoint')
        expect(TestModel.api_resource).to eq('custom_endpoint')
        TestModel.send(:endpoint=, nil)
      end
    end

    describe '.entity_name' do
      it do
        expect(TestModel.entity_name).to eq('test_model')
      end
    end

    describe '.primary_key' do
      it 'returns :id by default and custom value when set' do
        expect(TestModel.primary_key).to eq(:id)
        TestModel.send(:primary_key=, :uuid)
        expect(TestModel.primary_key).to eq(:uuid)
        TestModel.send(:primary_key=, nil)
      end
    end

    describe 'delegated methods from query' do
      it 'responds to delegated query methods' do
        %i[all find_each page per page_size order select where first find_by count].each do |method|
          expect(TestModel).to respond_to(method)
        end
      end
    end
  end

  describe 'protected method' do
    describe '.entity_key' do
      it 'returns entity name by default and custom value when set' do
        expect(TestModel.send(:entity_key)).to eq('test_model')
        TestModel.send(:entity_key=, 'my_key')
        expect(TestModel.send(:entity_key)).to eq('my_key')
        TestModel.send(:entity_key=, nil)
      end
    end

    describe '.query' do
      it 'returns a Magento::Query instance' do
        expect(TestModel.send(:query)).to be_a(Magento::Query)
      end
    end

    describe '.request' do
      it 'returns a Magento::Request instance' do
        allow(TestModel).to receive(:request).and_call_original
        expect(TestModel.send(:request)).to be_a(Magento::Request)
      end
    end
  end
end