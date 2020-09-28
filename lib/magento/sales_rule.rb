module Magento
  class SalesRule < Model
    self.primary_key = :rule_id
    self.entity_key = :rule
    self.endpoint = 'salesRules'

    # Example
    # rule = Magento::SalesRule.find(5)
    # rule.generate_coupon(quantity: 1, length: 10)
    #
    # @return {String[]}
    def generate_coupon(attributes)
      body = { couponSpec: { rule_id: id }.merge(attributes) }
      self.class.generate_coupon(body)
    end

    class << self
      # Example
      # Magento::SalesRule.generate_coupon(
      #   couponSpec: {
      #     rule_id: 5,
      #     quantity: 1,
      #     length: 10
      #   }
      # )
      # @return {String[]}
      def generate_coupon(attributes)
        request.post('coupons/generate', attributes).parse
      end
    end
  end
end
