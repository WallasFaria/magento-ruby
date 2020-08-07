module Magento
  class Customer < Model
    def fullname
      "#{@firstname} #{@lastname}"
    end

    class << self
      alias_method :find_by_id, :find

      def find_by_token(token)
        user_request = Request.new(token: token)
        customer_hash = user_request.get('customers/me').parse
        build(customer_hash)
      end
    end
  end
end
