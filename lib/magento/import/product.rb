module Magento
  module Import
    class Product
      def initialize(images_path, website_ids)
        @images_path = images_path
        @website_ids = website_ids
      end
  
      def import(products)
        products.each do |product|
          params = Magento::Params::CreateProduct.new(
            sku: product.sku,
            name: product.name.gsub(/[ ]+/, ' '),
            description: product.description || product.name,
            brand: product.brand,
            price: product.price.to_f,
            special_price: product.special_price ? product.special_price.to_f : nil,
            quantity: numeric?(product.quantity) ? product.quantity.to_f : 0,
            weight: 0.3,
            manage_stock: numeric?(product.quantity),
            attribute_set_id: 4,
            category_ids: [product.cat1, product.cat2, product.cat3].compact,
            website_ids: @website_ids,
            images: images(product)
          ).to_h
  
          product = Magento::Product.create(params)
  
          puts "Produto criado: #{product.sku} => #{product.name}"
        rescue => e
          puts "Erro ao criado: #{product.sku} => #{product.name}"
          puts " - Detalhes do erro: #{e}"
        end
      end
  
      private
  
      def images(product)
        image = find_image(product)
        return [] unless image
  
        Magento::Params::CreateImage.new(
          path: image,
          title: product.name,
          position: 0,
          main: true
        ).variants
      end
  
      def find_image(product)
        prefix = "#{@images_path}/#{product.sku}"
  
        extensions = %w[jpg jpeg png webp]
        extensions.map { |e| ["#{prefix}.#{e}", "#{prefix}.#{e.upcase}"] }.flatten
                  .find { |file| File.exist?(file) }
      end
  
      def numeric?(value)
        !!(value.to_s =~ /^[\d]+$/)
      end
    end
  end
end
