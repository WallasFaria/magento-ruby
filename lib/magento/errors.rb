module Magento
  class NotFoundError < StandardError; end
  class UnauthorizedAccessError < StandardError; end
  class UnprocessedRequestError < StandardError; end
end