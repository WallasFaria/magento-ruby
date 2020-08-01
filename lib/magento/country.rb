module Magento
  class Country < Model
    class << self
      def find(code)
        country_hash = request.get("directory/countries/#{code}").parse
        map_hash Country, country_hash
      end
    end
  end
end
