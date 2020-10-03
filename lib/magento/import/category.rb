module Magento
  module Import
    class Category
      def initialize(products)
        @products = products
        @category_root = Magento::Category.all
        @cats = @category_root.children_data
      end

      def associate
        @products.each do |prod|
          cat1 = find_or_create(name: prod.cat1, parent: @category_root) if prod.cat1
          cat2 = find_or_create(name: prod.cat2, parent: cat1) if prod.cat2
          cat3 = find_or_create(name: prod.cat3, parent: cat2) if prod.cat3

          prod.cat1, prod.cat2, prod.cat3 = cat1&.id, cat2&.id, cat3&.id

          @cats.push(*[cat1, cat2, cat3].compact)
        end
      end

      private

      def find_or_create(name:, parent:)
        find(name, cats: @cats, parent_id: parent.id) || create(name, parent: parent)
      end

      def find(name, cats:, parent_id:)
        cats.each do |cat|
          return cat if cat.name == name && cat.parent_id == parent_id

          if cat.respond_to?(:children_data) && cat.children_data&.size.to_i > 0
            result = find(name, cats: cat.children_data, parent_id: parent_id)
            return result if result
          end
        end
        nil
      end

      def create(name, parent:)
        params = Magento::Params::CreateCategoria.new(
          name: name,
          parent_id: parent.id,
          url: "#{Magento.store}-#{parent.id}-#{name.parameterize}"
        )

        Magento::Category.create(params.to_h).tap { |c| puts "Create: #{c.id} => #{c.name}" }
      end
    end
  end
end
