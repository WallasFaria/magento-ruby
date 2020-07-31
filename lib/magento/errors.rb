# frozen_string_literal: true

module Magento
  class MagentoError < StandardError
    attr_reader :status
    attr_reader :errors
    attr_reader :request

    def initialize(msg = '', status = 400, errors = nil, request = nil)
      @status  = status
      @errors  = errors
      @request = request
      super(msg)
    end
  end

  class NotFound < MagentoError; end
end
