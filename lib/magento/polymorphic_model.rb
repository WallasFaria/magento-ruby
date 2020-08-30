module Magento
  class PolymorphicModel
    attr_reader :api_resource

    def initialize(model, api_resource)
      @model = model
      @api_resource = api_resource
    end

    def new
      @model.new
    end

    def build(attributes)
      @model.build(attributes)
    end
  end
end