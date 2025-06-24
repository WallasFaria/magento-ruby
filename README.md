# Magento 2 Ruby library

Ruby library to consume the magento 2 api

> Tested in version 2.3 of magento

[Getting started](#getting-started)
  - [Install](#install)
  - [Setup](#setup)

[Model common methods](#model-common-methods)
  - [find](#find)
  - [find_by](#find_by)
  - [first](#first)
  - [count](#count)
  - [all](#count)
  - [create](#create)
  - [update](#update)
  - [delete](#delete)

[Search criteria](#search-criteria)
  - [Select fields](#select-fields)
  - [Filters](#filters)
  - [Sort order](#sort-order)
  - [Pagination](#pagination)
- [Record Collection](#record-collection)

**Additional methods**

[Product](#product)
  - [Shurtcuts](#shurtcuts)
  - [Update stock](#update-stock)
  - [Add media](#add-media-to-product)
  - [Remove media](#remove-media-from-product)
  - [Add tier price](#add-tier-price-to-product)
  - [Remove tier price](#remove-tier-price-from-product)
  - [Create links](#create-links-to-product)
  - [Remove link](#remove-link-from-product)

[Order](#order)
  - [Invoice](#invoice-an-order)
  - [Offline Refund](#create-offline-refund-for-order)
  - [Creates new Shipment](#creates-new-shipment-for-given-order)
  - [Cancel](#cancel-an-order)

[Invoice](#invoice)
  - [Refund](#create-refund-for-invoice)
  - [Capture](#capture-an-invoice)
  - [Void](#void-an-invoice)
  - [Send email](#send-invoice-email)
  - [Get comments](#get-invoice-comments)

[Sales Rule](#sales-rule)
  - [Generate Sales Rules and Coupons](#generate-sales-rules-and-coupons)

[Customer](#customer)
  - [Find by token](#get-customer-by-token)
  - [Login](#customer-login)
  - [Reset Password](#customer-reset-password)

[Guest cart](#guest-cart)
  - [Payment information](#payment-information)
  - [Add Coupon](#add-coupon-to-guest-cart)
  - [Remove Coupon](#remove-coupon-from-guest-cart)

[Inventory](#invoice)
  - [Check whether a product is salable](#check-whether-a-product-is-salable)
  - [Check whether a product is salable for a specified quantity](#check-whether-a-product-is-salable-for-a-specified-quantity)

**Helper classes**

- [Create product params](#create-product-params)
- [Create product image params](#create-product-image-params)
- [Import products from csv file](#import-products-from-csv-file)

## Getting started

### Install
Add in your Gemfile

```rb
gem 'magento', '~> 0.31.0'
```

or run

```sh
gem install magento
```

### Setup

```rb
Magento.configure do |config|
  config.url   = 'https://yourstore.com'
  config.token = 'MAGENTO_API_KEY'
  config.store = :default # optional, Default is :all
end

Magento.with_config(store: :other_store) do # accepts store, url and token parameters
  Magento::Product.find('sku')
end
```

## Model common methods

All classes that inherit from `Magento::Model` have the methods described below

### `find`

Get resource details with the `find` method

Example:
```rb
Magento::Product.find('sku-test')
Magento::Order.find(25)
Magento::Country.find('BR')
```

### `find_by`

Returns the first resource found based on the argument passed

Example:
```rb
Magento::Product.find_by(name: 'Some product name')
Magento::Customer.find_by(email: 'customer@email.com')
```

### `first`

Returns the first resource found for the [search criteria](#search-criteria)

Example:
```rb
Magento::Order.where(grand_total_gt: 100).first
```

### `count`

Returns the total amount of the resource, also being able to use it based on the [search criteria](#search-criteria)

Example:
```rb

Magento::Order.count
>> 1500

Magento::Order.where(status: :pending).count
>> 48
```

### `all`

Used to get a list of a specific resource based on the [search criteria](#search-criteria).

Returns a [Record Collection](#record-collection)

Example:
```rb
# Default search criteria:
#  page: 1
#  page_size: 50
Magento::Product.all

Magento::Product
  .order(created_at: :desc)
  .page_size(10)
  .all
```

### `create`

Creates a new resource based on reported attributes.

Consult the magento documentation for available attributes for each resource:

Documentation links:
- [Product](https://magento.redoc.ly/2.3.6-admin/tag/products#operation/catalogProductRepositoryV1SavePost)
- [Category](https://magento.redoc.ly/2.3.6-admin/tag/categories#operation/catalogCategoryRepositoryV1SavePost)
- [Order](https://magento.redoc.ly/2.3.6-admin/tag/orders#operation/salesOrderRepositoryV1SavePost)
- [Customer](https://magento.redoc.ly/2.3.6-admin/tag/customers#operation/customerAccountManagementV1CreateAccountPost)

Example:
```rb
Magento::Order.create(
  customer_firstname: '',
  customer_lastname: '',
  customer_email: '',
  # others attrbutes ...,
  items: [
    {
      sku: '',
      price: '',
      qty_ordered: 1,
      # others attrbutes ...,
    }
  ],
  billing_address: {
    # attrbutes...
  },
  payment: {
    # attrbutes...
  },
  extension_attributes: {
    # attrbutes...
  }
)
```

#### `update`

Update a resource attributes.

Example:

```rb
Magento::Product.update('sku-teste', name: 'Updated name')

# or by instance method

product = Magento::Product.find('sku-teste')

product.update(name: 'Updated name', status: '2')

# or save after changing the object

product.name = 'Updated name'
product.save
```

### `delete`

Delete a especific resource.

```rb
Magento::Product.delete('sku-teste')

# or
product = Magento::Product.find('sku-teste')
product.delete
```

## Search Criteria

They are methods used to assemble the search parameters

All methods return an instance of the `Magento::Query` class. The request is only executed after calling method `all`.

Example:

```rb
customers = Magento::Customer
  .where(dob_gt: '1995-01-01')
  .order(:dob)
  .all

# or

query = Magento::Customer.where(dob_gt: '1995-01-01')

query = query.order(:dob) if ordered_by_date_of_birth

customers = query.all
```

### Select fields:

Example:
```rb
Magento::Product.select(:id, :sku, :name).all

Magento::Product
  .select(
    :id,
    :sku,
    :name,
    extension_attributes: :category_links
  )
  .all

Magento::Product
  .select(
    :id,
    :sku,
    :name,
    extension_attributes: [
      :category_links,
      :website_ids
    ]
  )
  .all

Magento::Product
  .select(
    :id,
    :sku,
    :name,
    extension_attributes: [
      { category_links: :category_id },
      :website_ids
    ]
  )
  .all
```

### Filters

Example:
```rb
Magento::Product.where(visibility: 4).all
Magento::Product.where(name_like: 'IPhone%').all
Magento::Product.where(price_gt: 100).all

# price > 10 AND price < 20
Magento::Product.where(price_gt: 10)
                .where(price_lt: 20).all

# price < 1 OR price > 100
Magento::Product.where(price_lt: 1, price_gt: 100).all

Magento::Order.where(status_in: [:canceled, :complete]).all

```

| Condition | Notes |
| --------- | ----- |
|eq         | Equals. |
|finset     | A value within a set of values |
|from       | The beginning of a range. Must be used with to |
|gt         | Greater than |
|gteq       | Greater than or equal |
|in         | In. The value is an array |
|like       | Like. The value can contain the SQL wildcard characters when like is specified. |
|lt         | Less than |
|lteq       | Less than or equal |
|moreq      | More or equal |
|neq        | Not equal |
|nfinset    | A value that is not within a set of values |
|nin        | Not in. The value is an array |
|notnull    | Not null |
|null       | Null |
|to         | The end of a range. Must be used with from |


### Sort Order

Example:
```rb
Magento::Product.order(:sku).all
Magento::Product.order(sku: :desc).all
Magento::Product.order(status: :desc, name: :asc).all
```

### Pagination:

Example:
```rb
# Set page and quantity per page
Magento::Product
  .page(1)       # Current page, Default is 1
  .page_size(25) # Default is 50
  .all

# per is an alias to page_size
Magento::Product.per(25).all
```

## Record Collection

The `all` method retorns a `Magento::RecordCollection` instance

Example:
```rb
products = Magento::Product.all

products.first
>> <Magento::Product @sku="2100", @name="Biscoito Piraque Salgadinho 100G">

products[0]
>> <Magento::Product @sku="2100", @name="Biscoito Piraque Salgadinho 100G">

products.last
>> <Magento::Product @sku="964", @name="Biscoito Negresco 140 G Original">

products.map(&:sku)
>> ["2100", "792", "836", "913", "964"]

products.size
>> 5

products.current_page
>> 1

products.next_page
>> 2

products.last_page?
>> false

products.page_size
>> 5

products.total_count
>> 307

products.filter_groups
>> [<Magento::FilterGroup @filters=[<Magento::Filter @field="name", @value="biscoito%", @condition_type="like">]>]
```

All Methods:

```rb
# Information about search criteria
:current_page
:next_page
:last_page?
:page_size
:total_count
:filter_groups

# Iterating with the list of items
:count
:length
:size

:first
:last
:[]
:find

:each
:each_with_index
:sample

:map
:select
:filter
:reject
:collect
:take
:take_while

:sort
:sort_by
:reverse_each
:reverse

:all?
:any?
:none?
:one?
:empty?
```

## Product

### Shurtcuts

Shurtcut to get custom attribute value by custom attribute code in product

Exemple:

```rb
product.attr :description
# it is the same as
product.custom_attributes.find { |a| a.attribute_code == 'description' }&.value

# or
product.description
```

when the custom attribute does not exists:

```rb
product.attr :special_price
> nil

product.special_price
> NoMethodError: undefined method `special_price' for #<Magento::Product:...>
```

```rb
product.respond_to? :special_price
> false

product.respond_to? :description
> true
```

Shurtcut to get product stock and stock quantity

```rb
product = Magento::Product.find('sku')

product.stock
> <Magento::StockItem @item_id=7243, @product_id=1221, ...>

product.stock_quantity
> 22
```

### Update stock

Update product stock

```rb
product = Magento::Product.find('sku')
product.update_stock(qty: 12, is_in_stock: true)

# or through the class method

Magento::Product.update_stock('sku', id, {
  qty: 12,
  is_in_stock: true
})
```

> see all available attributes in: [Magento Rest Api Documentation](https://magento.redoc.ly/2.4.1-admin/tag/productsproductSkustockItemsitemId)


### Add media to product

Create new gallery entry

Example:
```rb
product = Magento::Product.find('sku')

image_params = {
  media_type: 'image',
  label: 'Image label',
  position: 1,
  content: {
    base64_encoded_data: '/9j/4QAYRXhpZgAASUkqAAgAAAAAAAAA...',
    type: 'image/jpg',
    name: 'filename.jpg'
  },
  types: ['image']
}

product.add_media(image_params)

# or through the class method

Magento::Product.add_media('sku', image_params)
```
> see all available attributes in: [Magento Rest Api Documentation](https://magento.redoc.ly/2.3.6-admin/#operation/catalogProductAttributeMediaGalleryManagementV1CreatePost)


you can also use the `Magento::Params::CreateImage` helper class

```rb
params = Magento::Params::CreateImage.new(
  title: 'Image title',
  path: '/path/to/image.jpg', # or url
  position: 1,
).to_h

product.add_media(params)
```

> see more about [Magento::Params::CreateImage](lib/magento/params/create_image.rb#L9)

### Remove media from product

Example:
```rb
product = Magento::Product.find('sku')

product.add_media(media_id)

# or through the class method

Magento::Product.add_media('sku', media_id)
```

### Add tier price to product

Add `price` on product `sku` for specified `customer_group_id`

The `quantity` params is the minimun amount to apply the price
```rb
product = Magento::Product.find('sku')
product.add_tier_price(3.99, quantity: 1, customer_group_id: :all)

# or through the class method

Magento::Product.add_tier_price('sku', 3.99, quantity: 1, customer_group_id: :all)
```

### Remove tier price from product

```rb
product = Magento::Product.find(1)
product.remove_tier_price(quantity: 1, customer_group_id: :all)

# or through the class method

Magento::Product.remove_tier_price('sku', quantity: 1, customer_group_id: :all)
```

### Create links to product

Assign a product link to another product

Example:
```rb
product = Magento::Product.find('sku')

link_param = {
  link_type: 'upsell',
  linked_product_sku: 'linked_product_sku',
  linked_product_type: 'simple',
  position: 1,
  sku: 'sku'
}

product.create_links([link_param])

# or through the class method

Product.create_links('sku', [link_param])
```

### Remove link from product

Example:
```rb
product = Magento::Product.find('sku')

product.remove_link(link_type: 'simple', linked_product_sku: 'linked_product_sku')

# or through the class method

Product.remove_link(
  'sku',
  link_type: 'simple',
  linked_product_sku: 'linked_product_sku'
)
```

## Order

### Invoice an Order

Example:
```rb
Magento::Order.invoice(order_id)
>> 25 # return incoice id

# or from instance

order = Magento::Order.find(order_id)

invoice_id = order.invoice

# you can pass parameters too

invoice_id = order.invoice(
  capture: false,
  appendComment: true,
  items: [{ order_item_id: 123, qty: 1 }], # pass items to partial invoice
  comment: {
    extension_attributes: { },
    comment: "string",
    is_visible_on_front: 0
  },
  notify: true
)
```

[Complete Invoice Documentation](https://magento.redoc.ly/2.4-admin/tag/orderorderIdinvoice#operation/salesInvoiceOrderV1ExecutePost)

### Create offline refund for order

Example:
```rb
Magento::Order.refund(order_id)
>> 12 # return refund id

# or from instance

order = Magento::Order.find(order_id)

order.refund

# you can pass parameters too

order.refund(
  items: [
    {
      extension_attributes: {},
      order_item_id: 0,
      qty: 0
    }
  ],
  notify: true,
  appendComment: true,
  comment: {
    extension_attributes: {},
    comment: string,
    is_visible_on_front: 0
  },
  arguments: {
    shipping_amount: 0,
    adjustment_positive: 0,
    adjustment_negative: 0,
    extension_attributes: {
      return_to_stock_items: [0]
    }
  }
)
```

[Complete Refund Documentation](https://magento.redoc.ly/2.4-admin/tag/invoicescomments#operation/salesRefundOrderV1ExecutePost)

### Creates new Shipment for given Order.

Example:
```rb
Magento::Order.ship(order_id)
>> 25 # return shipment id

# or from instance

order = Magento::Order.find(order_id)

order.ship

# you can pass parameters too

order.ship(
  capture: false,
  appendComment: true,
  items: [{ order_item_id: 123, qty: 1 }], # pass items to partial shipment
  tracks: [
    {
      extension_attributes: { },
      track_number: "string",
      title: "string",
      carrier_code: "string"
    }
  ]
  notify: true
)
```

[Complete Shipment Documentation](https://magento.redoc.ly/2.4-admin/tag/orderorderIdship#operation/salesShipOrderV1ExecutePost)


### Cancel an Order

Example:
```rb
order = Magento::Order.find(order_id)

order.cancel # or

Magento::Order.cancel(order_id)
```

### Add a comment on given Order

Example:
```rb
order = Magento::Order.find(order_id)

order.add_comment(
  'comment',
  is_customer_notified: 0,
  is_visible_on_front: 1
)

# or

Magento::Order.add_comment(
  order_id,
  'comment',
  is_customer_notified: 0,
  is_visible_on_front: 1
)
```

## Invoice

### Create refund for invoice

Example:
```rb
Magento::Invoice.invoice(invoice_id)
>> 12 # return refund id

# or from instance

invoice = Magento::Invoice.find(invoice_id)

refund_id = invoice.refund

# you can pass parameters too

invoice.refund(
  items: [
    {
      extension_attributes: {},
      order_item_id: 0,
      qty: 0
    }
  ],
  isOnline: true,
  notify: true,
  appendComment: true,
  comment: {
    extension_attributes: {},
    comment: string,
    is_visible_on_front: 0
  },
  arguments: {
    shipping_amount: 0,
    adjustment_positive: 0,
    adjustment_negative: 0,
    extension_attributes: {
      return_to_stock_items: [0]
    }
  }
)
```

[Complete Refund Documentation](https://magento.redoc.ly/2.4-admin/tag/invoicescomments#operation/salesRefundInvoiceV1ExecutePost)

### Capture an invoice

Example:
```rb
invoice = Magento::Invoice.find(invoice_id)
invoice.capture

# or through the class method
Magento::Invoice.capture(invoice_id)
```

### Void an invoice

Example:
```rb
invoice = Magento::Invoice.find(invoice_id)
invoice.void

# or through the class method
Magento::Invoice.void(invoice_id)
```

### Send invoice email

Example:
```rb
invoice = Magento::Invoice.find(invoice_id)
invoice.send_email

# or through the class method
Magento::Invoice.send_email(invoice_id)
```

### Get invoice comments

Example:
```rb
Magento::Invoice.comments(invoice_id).all
Magento::Invoice.comments(invoice_id).where(created_at_gt: Date.today.prev_day).all
```

## Sales Rules

### Generate Sales Rules and Coupons

```rb
rule = Magento::SalesRule.create(
  name: 'Discount name',
  website_ids: [1],
  customer_group_ids: [0,1,2,3],
  uses_per_customer: 1,
  is_active: true,
  stop_rules_processing: true,
  is_advanced: false,
  sort_order: 0,
  discount_amount: 100,
  discount_step: 1,
  apply_to_shipping: true,
  times_used: 0,
  is_rss: true,
  coupon_type: 'specific',
  use_auto_generation: true,
  uses_per_coupon: 1
)

rule.generate_coupon(quantity: 1, length: 10)
```

Generate by class method
```rb
Magento::SalesRule.generate_coupon(
  couponSpec: {
    rule_id: 7,
    quantity: 1,
    length: 10
  }
)
```
> see all params in:
[Magento docs Coupon](https://magento.redoc.ly/2.3.5-admin/tag/couponsgenerate#operation/salesRuleCouponManagementV1GeneratePost) and
[Magento docs SalesRules](https://magento.redoc.ly/2.3.5-admin/tag/salesRules#operation/salesRuleRuleRepositoryV1SavePost)


## Customer

### Get customer by token
```rb
Magento::Customer.find_by_token('user_token')
```

### Customer login
Exemple:
```rb
Magento::Customer.login('username', 'password')

>> 'aj8oer4eQi44FrghgfhVdbBKN' #return user token
```

### Customer reset password
Exemple:
```rb
Magento::Customer.reset_password(
    email: 'user_email',
    reset_token: 'user_reset_token',
    new_password: 'user_new_password'
  )

>> true # return true on success
```

## Guest Cart

### Payment information
Set payment information to finish the order

Example:
```rb
cart = Magento::GuestCart.find('gXsepZcgJbY8RCJXgGioKOO9iBCR20r7')

# or use "build" to not request information from the magento API
cart = Magento::GuestCart.build(
  cart_id: 'aj8oUtY1Qi44Fror6UWVN7ftX1idbBKN'
)

cart.payment_information(
  email: 'customer@gmail.com',
  payment: { method: 'cashondelivery' }
)

>> "234575" # return the order id
```

### Add coupon to guest cart

Example:
```rb
cart = Magento::GuestCart.find('gXsepZcgJbY8RCJXgGioKOO9iBCR20r7')

cart.add_coupon('COAU4HXE0I')
# You can also use the class method
Magento::GuestCart.add_coupon('gXsepZcgJbY8RCJXgGioKOO9iBCR20r7', 'COAU4HXE0I')

>> true # return true on success
```

### Remove coupon from guest cart

Example:
```rb
cart = Magento::GuestCart.find('gXsepZcgJbY8RCJXgGioKOO9iBCR20r7')

cart.delete_coupon()
# You can also use the class method
Magento::GuestCart.delete_coupon('gXsepZcgJbY8RCJXgGioKOO9iBCR20r7')

>> true # return true on success
```

## Inventory

### Check whether a product is salable

Example:
```rb
Inventory.get_product_salable_quantity(sku: '4321', stock_id: 1)
>> 1
```

### Check whether a product is salable for a specified quantity

Example:
```rb
Inventory.is_product_salable_for_requested_qty(
  sku: '4321',
  stock_id: 1,
  requested_qty: 2
)
>> OpenStruct {
  :salable => false,
  :errors => [
    [0] {
      "code" => "back_order-disabled",
      "message" => "Backorders are disabled"
    },
    ...
  ]
}
```

## **Helper classes**

## Create product params

```rb
params = Magento::Params::CreateProduct.new(
  sku: '556-teste-builder',
  name: 'REFRIGERANTE PET COCA-COLA 1,5L ORIGINAL',
  description: 'Descrição do produto',
  brand: 'Coca-Cola',
  price: 4.99,
  special_price: 3.49,
  quantity: 2,
  weight: 0.3,
  attribute_set_id: 4,
  images: [
    *Magento::Params::CreateImage.new(
      path: 'https://urltoimage.com/image.jpg',
      title: 'REFRIGERANTE PET COCA-COLA 1,5L ORIGINAL',
      position: 1,
      main: true
    ).variants,
    Magento::Params::CreateImage.new(
      path: '/path/to/image.jpg',
      title: 'REFRIGERANTE PET COCA-COLA 1,5L ORIGINAL',
      position: 2
    )
  ]
)

Magento::Product.create(params.to_h)
```

## Create product image params

Helper class to create product image params.

before generating the hash, the following image treatments are performed:
- resize image
- remove alpha
- leaves square
- convert image to jpg

Example:
```rb
params = Magento::Params::CreateImage.new(
  title: 'Image title',
  path: '/path/to/image.jpg', # or url
  position: 1,
  size: 'small', # options: 'large'(defaut), 'medium' and 'small',
  disabled: true, # default is false,
  main: true, # default is false,
).to_h

Magento::Product.add_media('sku', params)
```

The resize defaut confiruration is:

```rb
Magento.configure do |config|
  config.product_image.small_size  = '200x200>'
  config.product_image.medium_size = '400x400>'
  config.product_image.large_size  = '800x800>'
end
```

## Import products from csv file

_TODO: exemple to [Magento::Import.from_csv](lib/magento/import.rb#L8)_

_TODO: exemple to [Magento::Import.get_csv_template](lib/magento/import.rb#L14)_


___


## **TODO:**

### Search products
```rb
Magento::Product.search('tshort')
```

### Last result
```rb
Magento::Product.last
>> <Magento::Product @sku="some-sku" ...>

Magento::Product.where(name_like: 'some name%').last
>> <Magento::Product @sku="some-sku" ...>
```

### Tests

___

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WallasFaria/magento_ruby.
