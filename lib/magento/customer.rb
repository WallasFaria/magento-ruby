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
        user_request = Request.new(config: Magento.configuration.copy_with(token: token))
        customer_hash = user_request.get('customers/me').parse
        build(customer_hash)
      end

      def find(id)
        hash = request.get("customers/#{id}").parse
        build(hash)
      end

      #
      # Log in to a user account
      #
      #   Example:
      #   Magento::Customer.login('customer@gmail.com', '123456')
      #
      # @return String: return the user token
      def login(username, password)
        user_token = request.post("integration/customer/token", {
          username: username, 
          password: password
        })
      end

      #
      # Reset a user's password
      #
      #   Example:
      #   Magento::Customer.reset_password(
      #     email: 'customer@gmail.com', 
      #     reset_token: 'mEKMTciuhPfWkQ3zHTCLIJNC',
      #     new_password: '123456'
      #   )
      #
      # @return Bolean: true on success, raise exception otherwise
      def reset_password(email:, reset_token:, new_password:)
        request.post("customers/resetPassword", {
            email: email,
            reset_token: reset_token,
            new_password: new_password
        }).parse
      end
    end
  end
end
