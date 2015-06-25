# GCFS Wrapper API Gem

A Ruby interface to the GCFS API.

## Installation
Add this to your Gemfile

    gem 'gcfs_wrapper_api', git: 'git://github.com/aksivisitama/gcfs_wrapper_api.git'

## Configuration
[GCFS API v1][gcfs] requires you to authenticate via [OAuth2][oauth], so you'll need to
[register your application with GCFS][register].

[gcfs]: http://docs.gcfspublicapi.apiary.io/
[register]: https://api.gcfs.com/
[oauth]: https://tools.ietf.org/html/rfc6749#section-4.3

Your new application will be assigned an api key/secret pair and you will
be assigned an GCFS account email/password pair for that application. You'll need
to configure these values before you make a request or else you'll get the
error:

```ruby
#<Gcfs::Wrapper::Api::Error: invalid_request>
```

You can pass configuration options as a block to `Gcfs::Wrapper::Api::configure`.

```ruby
Gcfs::Wrapper::Api::configure do |config|
  config.key      = 'Your API Key'
  config.secret   = 'Your API Secret'
  config.username = 'Your GCFS Email Account'
  config.password = 'Your GCFS Password Account'
  config.endpoint = 'GCFS Endpoint' #https://api.gcfs.com/
  config.debug    = true #optional, default false
end
```

## Usage Examples
All requests require an access token. 

### Token

**Request Token**

```ruby
token = Gcfs::Wrapper::Api::Token.request
```

It will generate:

```ruby
#<Gcfs::Wrapper::Api::Token: @access_token="602a16b2dd0cd18027f8bc9387786ae9", @expired_at=2015-04-30 09:14:56 +0700, @expires_in=2592000>
```

You can see generated token using:

```ruby
Gcfs::Wrapper::Api.token
or
Gcfs::Wrapper::Api.options[:token]
```

After generate a `token`, you can do the following things.

### Category

**List All Categories**

```ruby
Gcfs::Wrapper::Api::Category.all
```

### Item

**List All Items**

```ruby
Gcfs::Wrapper::Api::Item.all
```

### Item Variant

**List All Item Variants**

```ruby
items = Gcfs::Wrapper::Api::Item.all
item = items.first
Gcfs::Wrapper::Api::ItemVariant.all item.id
```

### Order

**List All Orders**

```ruby
Gcfs::Wrapper::Api::Order.all
```

**List All Cities**
To make an order City required.
This will list of cities that registered for order.

```ruby
Gcfs::Wrapper::Api::City.all
```

**Create an Order**

```ruby
params = {
  "description": "Pembelian Voucher",
  "recepient": {
    "name": "Mr. Burnice Anderson",
    "email": "enrique.prosacco@kulas.net",
    "phone_number": "947.962.2387",
    "address": "Rasuna Said 10",
    "city": "dki jakarta", #Gcfs::Wrapper::Api::City @name
    "zip_code": "12950",
    "notes": "Pagar warna putih, Jika tidak ada orang di rumah harap ketuk rumah sebelah dan titipkan ke Ibu Dewi"
  },
  "items":[
    {
      "id": 1, #Gcfs::Wrapper::Api::Item @id
      "variants": [{
        "id": 1, #Gcfs::Wrapper::Api::ItemVariant @id
        "quantity": 10
      },
      {
        "id": 2,
        "quantity": 10
      }]
    },
    {
      "id": 2,
      "variants": [{
        "id": 3,
        "quantity": 10
      },
      {
        "id": 4,
        "quantity": 10
      }]
    }
  ],
  "metadata":{
    "user":{
      "id": 1, #Your App current_user's id
      "name": "Admin" #Your App current_user's name/email
    }
  }
}
order = Gcfs::Wrapper::Api::Order.create params
```

**Create an Order with address type**

```ruby
params = {
  "description": "Pembelian Voucher",
  "recepient": {
    "name": "Mr. Burnice Anderson",
    "email": "enrique.prosacco@kulas.net",
    "phone_number": "947.962.2387",
    "address_type": "home",
    "address": "Rasuna Said 10",
    "rt_rw": "03/01",
    "city": "dki jakarta", #Gcfs::Wrapper::Api::City @name
    "zip_code": "12950",
    "notes": "Pagar warna putih, Jika tidak ada orang di rumah harap ketuk rumah sebelah dan titipkan ke Ibu Dewi"
  },
  "items":[
    {
      "id": 1, #Gcfs::Wrapper::Api::Item @id
      "variants": [{
        "id": 1, #Gcfs::Wrapper::Api::ItemVariant @id
        "quantity": 10
      },
      {
        "id": 2,
        "quantity": 10
      }]
    }
  ],
  "metadata":{
    "user":{
      "id": 1, #Your App current_user's id
      "name": "Admin" #Your App current_user's name/email
    }
  }
}
order = Gcfs::Wrapper::Api::Order.create params
```

```ruby
params = {
  "description": "Pembelian Voucher",
  "recepient": {
    "name": "Mr. Burnice Anderson",
    "email": "enrique.prosacco@kulas.net",
    "phone_number": "947.962.2387",
    "address_type": "office",
    "company_name": "Giftcard Indonesia",
    "division_or_floor": "Floor 11th",
    "building_name": "Menara Imperium",
    "address": "Rasuna Said 10",
    "city": "dki jakarta", #Gcfs::Wrapper::Api::City @name
    "zip_code": "12950",
    "notes": "Pagar warna putih, Jika tidak ada orang di rumah harap ketuk rumah sebelah dan titipkan ke Ibu Dewi"
  },
  "items":[
    {
      "id": 1, #Gcfs::Wrapper::Api::Item @id
      "variants": [{
        "id": 1, #Gcfs::Wrapper::Api::ItemVariant @id
        "quantity": 10
      },
      {
        "id": 2,
        "quantity": 10
      }]
    }
  ],
  "metadata":{
    "user":{
      "id": 1, #Your App current_user's id
      "name": "Admin" #Your App current_user's name/email
    }
  }
}
order = Gcfs::Wrapper::Api::Order.create params
```

**Show Order**

```ruby
Gcfs::Wrapper::Api::Order.find(1)
```

### Flight

**Search flight according to date, destination, and number of passangers**
```ruby
params = {
    "d":"CGK",
    "a":"DPS",
    "date":"2015-04-28",
    "ret_date":"2015-04-30",
    "adult":"2",
    "child":"0",
    "infant":"1",
    "sort":"priceasc",
    "metadata":{
        "user":{
            "id": 1, #Your App current_user's id
            "name": "Admin" #Your App current_user's email
        }
    }
}
search = Gcfs::Wrapper::Api::Flight.search params
```

**Create Flight Order**
```ruby
params = {
  "flight_id": "960685",
  "ret_flight_id": "144355",
  "date": "2015-08-09",
  "adult": 1,
  "conSalutation": "Mrs",
  "conFirstName": "Jessica",
  "conLastName": "Kim",
  "conPhone": "6287880182218",
  "conEmailAddress": "jess@kim.com",
  "firstnamea1": "Jessica",
  "lastnamea1": "Kim",
  "birthdatea1": "1988-02-02",
  "ida1": "1234567890",
  "titlea1": "Ms",
  "conOtherPhone": "6287880182236",
  "passportnoa1": "A37365",
  "passportExpiryDatea1": "2017-07-30",
  "passportissueddatea1": "2012-07-30",
  "passportissuinga1": "id",
  "passportnationalitya1": "id",
  "dcheckinbaggagea11": 0,
  "rcheckinbaggagea11": 20,
  "recepient": {
    "name": "Scarlett",
    "email": "windiana88@hotmail.com",
    "phone_number": "08155566945"
  },
  "metadata": {
    "user": {
      "id": 1,
      "name": "windiana@giftcard.co.id"
    }
  }
}
order = Gcfs::Wrapper::Api::Flight.process_order params
```

**Get Airport List**
```ruby
params = {
  metadata: {
    user: {
      id: 1,
      name: "windiana@giftcard.co.id"
    }
  }
}
search = Gcfs::Wrapper::Api::Flight.airports params
```

### Hotel

**Search Hotel according to date, destination, and number of guest**
```ruby
params_search = {
    "q":"legian", 
    "startdate":"2015-04-28",
    "enddate":"2015-04-30",
    "night":"1", 
    "room":"1", 
    "adult"=>"2", 
    "child"=>"0", 
    "minprice"=>"", 
    "maxprice"=>"", 
    "minstar"=>"", 
    "maxstar"=>"", 
    "latitude"=>"", 
    "longitude" =>"",  
    "uid"=>"",
    "metadata":{
        "user":{ 
            "id":1, #Your App current_user's id
            "name":'derri@giftcard.co.id' #Your App current_user's email
        }
    }
}
search = Gcfs::Wrapper::Api::Hotel.search params_search
```

**Search Autocomplete**
```ruby
params_auto = {
    "q":"legian",  #query, it can be name hotel, city, location etc  
    "metadata":{
        "user":{ 
            "id":1, #Your App current_user's id
            "name":'derri@giftcard.co.id' #Your App current_user's email
        }
    }
}
Gcfs::Wrapper::Api::Hotel.search_autocomplete params_auto
```

**Search Area**
```ruby
params_auto = {
    "uid":"city:178", #uid can be id,country,province
    "q":"legian",  #query, it can be name hotel, city, location etc ,this parameter is optional 
    "type":"province", #type can be province,city,kecamatan ,this parameter is optional
    "metadata":{
        "user":{ 
            "id":1, #Your App current_user's id
            "name":'derri@giftcard.co.id' #Your App current_user's email
        }
    }
}
Gcfs::Wrapper::Api::Hotel.search_area params_auto
```

**View detail hotel**
```ruby
params_detail_hotel = {
    "hotel_id":"4196",  #hotel_id, get hotel id from search hotel  
    "metadata":{
        "user":{ 
            "id":1, #Your App current_user's id
            "name":'derri@giftcard.co.id' #Your App current_user's email
        }
    }
}
Gcfs::Wrapper::Api::Hotel.view_detail params_detail_hotel
```

**Create Order hotel**
```ruby
params_order = {
    "room_id":"457757",
    "salutation":"Mr",  
    "firstName":"Leonardo",
    "lastName":"Silva",
    "phone":"08562969660", 
    "conSalutation":"Mr",
    "conFirstName":"Bima",
    "conLastName":"Rajasa", 
    "conEmailAddress": "bima@giftcard.co.id",
    "conPhone":"08562969660",
    "country":"ID", 
    "emailAddress": "bima@giftcard.co.id",
    "recepient": {
      "name": "Bima",
      "email": "bima.herla@gmail.com",
      "phone_number": "08562969660"
    },
    "metadata":{
        "user":{ 
            "id":1, #Your App current_user's id
            "name":"derri@giftcard.co.id" #Your App current_user's email
        }
    }
}
Gcfs::Wrapper::Api::Hotel.process_order params_order
```


### Datacell

**Get Datacell Product List**
```ruby
params = {
    "sort":{
      "operator": "asc | desc",
      "operator_code": "asc | desc"
    }
}
products = Gcfs::Wrapper::Api::Dtcell.all params
```

**Topup Phone Credit**
```ruby
params = {
  "operator_code": "TEL.10",
  "phone_number": "08188812345",
  "qty": 2,
  "transaction_id": "TrXih2834"
}
topup = Gcfs::Wrapper::Api::Dtcell.topup params
```

### Pagination

GCFS use pagination on all list request.

```ruby
default_per_page = 20
max_per_page = 100
```

You can access next page using page and per_page paramameter

```ruby
Gcfs::Wrapper::Api::Category.all page: 2
or 
Gcfs::Wrapper::Api::Category.all page: 1, per_page: 100
```

### Cached

`.all` request will be cached. To get new data you can pass force parameter

```ruby
Gcfs::Wrapper::Api::Category.all force: true
or 
Gcfs::Wrapper::Api::Category.all page: 1, per_page: 100, force: true
```

## Copyright
Copyright (c) 2015 Derri Mahendra giftcard.co.id.
See [LICENSE][] for details.

[license]: MIT-LICENSE
