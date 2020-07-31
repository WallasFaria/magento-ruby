module Magento
  module Error
    class NotFound < StandardError; end
    class UnauthorizedAccess < StandardError; end
    class UnprocessedRequest < StandardError; end
  end
end