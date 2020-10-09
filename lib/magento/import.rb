require_relative 'import/image_finder'
require_relative 'import/csv_reader'
require_relative 'import/category'
require_relative 'import/product'

module Magento
  module Import
    def self.from_csv(file, images_folder: nil, website_ids: [0])
      products = CSVReader.new(file).get_products
      products = Category.new(products).associate
      Product.new(website_ids, images_folder).import(products)
    end

    def self.get_csv_template
      File.open(__dir__ + '/import/template/products.csv')
    end
  end
end
