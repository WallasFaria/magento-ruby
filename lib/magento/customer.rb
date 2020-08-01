module Magento
  class Customer < Model
    class << self
      def find_by_id(id)
        customer_hash = request.get("customers/#{id}").parse
        map_hash Customer, customer_hash
      end

      def find_by_token(token)
        user_request = Request.new(token: token)
        customer_hash = user_request.get('customers/me').parse
        map_hash Customer, customer_hash
      end
    end
  end
end
