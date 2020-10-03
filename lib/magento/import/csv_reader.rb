require 'csv'
require 'ostruct'

module Magento
  module Import
    class CSVReader
      def initialize(csv_file)
        @csv = CSV.read(csv_file, col_sep: ';')
      end

      def get_products
        @csv[1..].map do |row|
          name, sku, ean, description, price, special_price, quantity, cat1, cat2, cat3 = row
          OpenStruct.new({
            name: name,
            sku: sku,
            ean: ean,
            description: description,
            price: price,
            special_price: special_price,
            quantity: quantity,
            cat1: cat1,
            cat2: cat2,
            cat3: cat3
          })
        end
      end
    end
  end
end
