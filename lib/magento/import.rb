require_relative 'import/csv_reader'
require_relative 'import/category'
require_relative 'import/product'

module Magento
  module Import
    def self.from_csv(file, image_path:, website_ids: [0])
      products = CSVReader.new(file).get_products
      products = Category.new(products).associate
      Product.new(image_path, website_ids).import(products)
    end
  end
end
