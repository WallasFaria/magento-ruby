module Magento
  class Customer < Model
    self.endpoint = 'customers/search'

    def fullname
      "#{@firstname} #{@lastname}"
    end

    class << self
      alias_method :find_by_id, :find

      def update(*_attributes)
        raise NotImplementedError
      end

      def create(*_attributes)
        raise NotImplementedError
      end

      def find_by_token(token)
        user_request = Request.new(token: token)
        customer_hash = user_request.get('customers/me').parse
        build(customer_hash)
      end

      def find(id)
        hash = request.get("customers/#{id}").parse
        build(hash)
      end
    end
  end
end
