require 'csv'
require 'ostruct'

module Magento
  module Import
    class CSVReader
      def initialize(csv_file)
        @csv = CSV.read(csv_file, col_sep: ';')
      end

      def get_products
        @csv[1..-1].map do |row|
          OpenStruct.new({
            name: row[0],
            sku: row[1],
            ean: row[2],
            description: row[3],
            price: row[4],
            special_price: row[5],
            quantity: row[6],
            cat1: row[7],
            cat2: row[8],
            cat3: row[9],
            main_image: row[10]
          })
        end
      end
    end
  end
end
