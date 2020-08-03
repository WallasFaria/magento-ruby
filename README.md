# Magento Ruby library

## Install

Add in your Gemfile

```rb
gem 'magento', '~> 0.3.2'
```

or run

```sh
gem install magento
```

### Setup

```rb
Magento.url   = 'https://yourstore.com'
Magento.token = 'MAGENTO_API_KEY'
Magento.store = :default # optional, Default is :all
```

## Models
```rb
Magento::Product
Magento::Order
Magento::Country
Magento::Category
```

## Get details

```rb
Magento::Product.find('sku-test')
Magento::Order.find(25)
Magento::Country.find('BR')
```
\* _same pattern to all models_

**Outside pattern**

Get customer by token

```rb
Magento::Customer.find_by_token('user_token')
```

## Get List

```rb
Magento::Product.all
```

#### Select fields:
```rb
Magento::Product.select(:id, :sku, :name).all
Magento::Product.select(:id, :sku, :name, extension_attributes: :category_links).all
Magento::Product.select(:id, :sku, :name, extension_attributes: [:category_links, :website_ids]).all
Magento::Product.select(:id, :sku, :name, extension_attributes: [:website_ids, { category_links: :category_id }]).all
```

#### Filters:

```rb
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


#### SortOrder:

```rb
Magento::Product.order(:sku).all
Magento::Product.order(sku: :desc).all
Magento::Product.order(status: :desc, name: :asc).all
```

#### Pagination:

```rb
# Set page and quantity per page
Magento::Product.page(1).per(25) # Default per is 50
```

#### Example of several options together:
```rb
Magento::Product.select(:sku, :name, :price)
                .where(name_like: 'Tshort%')
                .order(price: :desc)
                .per(10)
                .all
```

\* _same pattern to all models_
___
## \######### TODO \##########

## Create

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

### Update

```rb
product = Magento::Product.find('sku-teste')

product.name = 'Updated name'
product.save

# or

product.update(name: 'Updated name')
```

### Delete

```rb
product = Magento::Product.find('sku-teste')

product.delete

# or

Magento::Product.delete('sku-teste')
```

### Search products
```rb
Magento::Product.search('tshort')
```
