require './lib/magento'

Magento.url   = 'https://maniadagua.com'
Magento.token = 'f44251o3xjijz8ou78hoyh8a06kdtkmh'

page = 245

loop do
  products = Magento::Product.page(page).per(5).all

  products.each do |product|
    Magento::Product.update(product.sku, extension_attributes: { website_ids: [1, 2] })
    puts "update page #{page}, product: #{product.name}"
  rescue => e
    puts "ERRO ao cadastrar: #{product.name}, #{e.message}"
  end

  break if products.last_page?
  page = products.next_page
end
