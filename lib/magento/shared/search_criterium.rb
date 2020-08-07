module Magento
  class SearchCriterium
    include Magento::ModelParser
    attr_accessor :current_page, :filter_groups, :page_size
  end
end
