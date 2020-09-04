module Magento
  class Customer < Model
    self.endpoint = 'customers/search'

    def fullname
      "#{@firstname} #{@lastname}"
    end

    def update(attributes)
      raise "id not present" if @id.nil?

      attributes.each { |key, value| send("#{key}=", value) }
      save
    end

    class << self
      alias_method :find_by_id, :find

      def update(id, attributes)
        hash = request.put("customers/#{id}", { customer: attributes }).parse

        block_given? ? yield(hash) : build(hash)
      end

      def create(attributes)
        attributes.transform_keys!(&:to_sym)
        password = attributes.delete :password
        hash = request.post("customers", {
          customer: attributes,
          password: password
        }).parse
        build(hash)
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
