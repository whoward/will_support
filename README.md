# WillSupport

WillSupport is a collection of ruby modules, objects and refinements that I have found useful over the years.  There is
no real focus on what is included - anything that I generally consider a 'utility' that doesn't really need to be it's
own gem goes in here.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'will_support'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install will_support

## Usage

By default no modules are loaded.  To use modules you must manually require them.

### Curry Module
```ruby
require 'will_support/curry'
```

The Curry module allows you to call a method with fewer arguments than are required and returns a curried `proc` object
instead.  The curried `proc` object can then be called any number of times with the remaining arguments.  As this is a
proc object this can be very powerful when used where the threequals (`===`) operator is used, such as in a `case/when`.

#### Example:

```ruby
module Tests
   extend WillSupport::Curry

   curry def integer?(x)
     case x
     when Fixnum then true
     when String then x =~ /^\d+$/
     else false
     end
   end

   curry def real?(x)
    case x
    when Fixnum, Float then true
    when String then x =~ /^\d+(\.\d+)?$/
    else false
    end
   end
end

# casting function, takes a numeric like argument and turns it into an integer.  Raises an ArgumentError if it cannot be casted.
def Integer(value)
  case value
  when Test.integer? then value.to_i
  when Test.real?
    warn 'possible loss of precision'
    value.to_i
  else
    raise ArgumentError, "Cannot cast #{value} to Integer"
  end
end
```

### Retry class
```ruby
  require 'will_support/retry'
```

TODO: write description

### Selenium module

The Selenium module requires you to also install the `selenium-webdriver` and `nokogiri` gems

```ruby
  require 'will_support/selenium'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/whoward/will_support.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
