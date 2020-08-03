module Magento
  class Customer < Model
    class << self
      alias_method :find_by_id, :find

      def find_by_token(token)
        user_request = Request.new(token: token)
        customer_hash = user_request.get('customers/me').parse
        ModelMapper.from_hash(customer_hash).to_model(Customer)
      end
    end
  end
end
