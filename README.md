# Magento Ruby library

## Install

Add in your Gemfile

```rb
gem 'magento', '~> 0.1.0'
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

## Product

### Get product details by sku

```rb
Magento::Product.find_by_sku('sku-test')
```

## Customer

### Get customer by id
```rb
Magento::Customer.find_by_id(id)
```

### Get customer by token
```rb
Magento::Customer.find_by_token('user_token')
```

## Countries

### Get available regions for a country

```rb
country = Magento::Country.find('BR')

country.available_regions
```

# TODO
### Get product list

Get all
```rb
Magento::Product.all()
```

Set page and quantity per page
```rb
Magento::Product.all(page: 1, page_size: 25) # Default page size is 50
```

Filter list by attribute
```rb
Magento::Product.all(name_like: 'IPhone%')

Magento::Product.all(price_gt: 100, page: 2)
```

### Search products
```rb
Magento::Product.search('tshort')
```

## Order

### Create Order as admin user

See the [documentation](https://magento.redoc.ly/2.4-admin/#operation/salesOrderRepositoryV1SavePost) to all attributes

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
