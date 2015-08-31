# Lotus::Mailer

Mail for Ruby applications.

## Status

[![Gem Version](http://img.shields.io/gem/v/lotus-mailer.svg)](https://badge.fury.io/rb/lotus-mailer)
[![Build Status](http://img.shields.io/travis/lotus/mailer/master.svg)](https://travis-ci.org/lotus/mailer?branch=master)
[![Coverage](http://img.shields.io/coveralls/lotus/mailer/master.svg)](https://coveralls.io/r/lotus/mailer)
[![Code Climate](http://img.shields.io/codeclimate/github/lotus/mailer.svg)](https://codeclimate.com/github/lotus/mailer)
[![Dependencies](http://img.shields.io/gemnasium/lotus/mailer.svg)](https://gemnasium.com/lotus/mailer)
[![Inline Docs](http://inch-ci.org/github/lotus/mailer.svg)](http://inch-ci.org/github/lotus/mailer)

## Contact

* Home page: http://lotusrb.org
* Mailing List: http://lotusrb.org/mailing-list
* API Doc: http://rdoc.info/gems/lotus-mailer
* Bugs/Issues: https://github.com/lotus/mailer/issues
* Support: http://stackoverflow.com/questions/tagged/lotus-ruby
* Chat: https://gitter.im/lotus/chat

## Rubies

__Lotus::Mailer__ supports Ruby (MRI) 2+.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lotus-mailer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lotus-mailer

## Usage

### Conventions

  * Templates are searched under `Lotus::Mailer.configuration.root`, set this value according to your app structure (eg. `"app/templates"`).
  * A mailer will look for a template with a file name that is composed by its full class name (eg. `"articles/index"`).
  * A template must have two concatenated extensions: one for the format and one for the engine (eg. `".html.erb"`).
  * The framework must be loaded before rendering the first time: `Lotus::Mailer.load!`.

### Mailers

A simple mailer looks like this:

```ruby
require lotus/mailer

class InvoiceMailer
  include Lotus::Mailer
end
```

A mailer with `to` and `from` addresses and mailer delivery:

```ruby
require lotus/mailer

class InvoiceMailer
  include Lotus::Mailer
  
  from 'noreply@sender.com'
  to 'noreply@recipient.com'
  subject 'Welcome'
end

CUSTOM_DELIVERY = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "localhost:8000",
  :user_name            => "noreply@sender.com",
  :password             => "password",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

Lotus::Mailer.configuration do
  delivery_method CUSTOM_DELIVERY
end

Lotus::Mailer.load!
InvoiceMailer.deliver
```

### Locals

The set of objects passed in the `deliver` call are called `locals` and are used to render templates that use objects with the same symbol.

```ruby
require lotus/mailer

class User
  def initialize(name, username)
    @name = name
    @username = username
  end

  attr_reader :name, :username
end

luca = User.new('Luca', 'jodosha')
InvoiceMailer.deliver(user:luca)
```

The corresponding `erb` file:

```erb
Hello <%= user.name %>!
```

### Scope

All methods defined in the mailer are accessible from the template:

```ruby
require lotus/mailer

class InvoiceMailer
  include Lotus::Mailer
  
  from 'noreply@sender.com'
  to 'noreply@recipient.com'
  subject 'Welcome'
  
  def greeting
    'Ahoy'
  end
end
```

```erb
<h2><%= greeting %></h2>
```

### Template

The template file must be located under the relevant `root` and must match the inflected snake case of the mailer class name.

```ruby
Lotus::Mailer.configuration.root      # => #<Pathname:app/templates>
InvoiceMailer.templates               # => "{:html => templateObject1; :txt => templateObject2}"
templateObject1.file                  # => "root/invoice_mailer.html.erb"
templateObject2.file                  # => "root/invoice_mailer.txt.erb"
```

Each mailer can specify a different template for a specific format:

```ruby
module Articles
  class Create
    include Lotus::View

    template :haml, 'invoice.haml.erb'
  end
end

InvoiceMailer.templates[:haml].file  # => "root/invoice.haml.erb"
```

### Engines

The builtin rendering engine is [ERb](http://en.wikipedia.org/wiki/ERuby).


### Configuration

__Lotus::Mailer__ can be configured with a DSL that determines its behavior.
It supports a few options:

```ruby
require 'lotus/mailer'

Lotus::Maler.configure do
  # Set the root path where to search for templates
  # Argument: String, Pathname, #to_pathname, defaults to the current directory
  #
  root '/path/to/root'

  # Set the Ruby namespace where to lookup for mailers
  # Argument: Class, Module, String, defaults to Object
  #
  namespace 'MyApp::Mailer'
```

All global configurations can be overwritten at a finer grained level:
`mailers`. Each `mailer` has its own copy of the global configuration, so
that changes are inherited from the top to the bottom, but not bubbled up in the
opposite direction.

Template lookup is performed under the `Lotus::Mailer.configuration.root` directory. You can specify a different path on a per mailer basis:

```ruby
require 'lotus/mailer'

Lotus::Mailer.configure do
  root '/path/to/root'
end

class MyMailer
  include Lotus::Mailer
  
  root '/another/root'
end

Lotus::Mailer.configuration.root   # => #<Pathname:/path/to/root>
MyMailer.root                      # => #<Pathname:/another/root>
```

### Delivery Details

When a Ruby object includes __Lotus::Mailer__, a developer can customize delivery details, such as `from`, `to` and `subject`.

The `from` field determines the sender of the email. It can accept a string:

```ruby
class InvoiceMailer
  include Lotus::Mailer

  from "noreply@example.com"
end
```

The `from` field can also accept a `Proc` to determine its value:

```ruby
class InvoiceMailer
  include Lotus::Mailer

  from -> { customized_sender }

  def customized_sender
    "user-#{ user.id }@example.com"
  end
end
```

The `to` field represents one or more emails that will be the recipients of the mail.

It can accept a string:

```ruby
class InvoiceMailer
  include Lotus::Mailer

  to "noreply@example.com"
end
```

The to field also accept an array of strings:

```ruby
class InvoiceMailer
  include Lotus::Mailer

  to %w(noreply1@example.com noreply2@example.com)
end
```

`To` field can also be configured using a `Proc` to determine its value:

```ruby
class InvoiceMailer
  include Lotus::Mailer

  to -> { customized_recipient }

  def customized_recipient
    "user-#{ user.id }@example.com"
  end
end
```

The subject of the message is determined by the field `subject`. It can accept a string:

```ruby
class InvoiceMailer
  include Lotus::Mailer

  subject "This is the subject"
end
```

The `subject` field can also accept a `Proc` to determine its value:

```ruby
class InvoiceMailer
  include Lotus::Mailer

  subject -> { customized_subject }

  def customized_subject
    "This is the subject"
  end
end
```

### Delivery method Configuration

The global delivery method is defined through the __Lotus::Mailer__ configuration, as:

```ruby
Lotus::Mailer.configuration do
  delivery_method :smtp
end
```

```ruby
Lotus::Mailer.configuration do
  delivery_method :smtp, address: "localhost", port:1025
end
```

or using the `delivery` alias:

```ruby
Lotus::Mailer.configuration do
  delivery :smtp
end
```

It is also possible to configure a custom delivery method with a variable:

```ruby
CUSTOM_DELIVERY = :smtp.freeze

Lotus::Mailer.configure do
  delivery CUSTOM_DELIVERY, foo:'bar'
end
```

The delivery method specified must be compatible with the `Mail` gem, and all `Mail` gem delivery methods are available in __Lotus::Mailer__.
See https://github.com/mikel/mail

### Multipart mail

Each template associated with the mailer will be used as a part of the email. 
The `.txt` template will be the `text_part` of the Mail object and the `.html` will correspond to the `html_part`.
Other formats will be added to the object as attachments.

The `deliver` method is necessary to send the multipart email. It looks at all the associated templates and renders them, as explained above. It instantiates a `mailer` and delivers the email.

```ruby
InvoiceMailer.deliver
```

To use `locals` when rendering templates, the `locals` must be used when calling the `deliver` method, like so:

```ruby
InvoiceMailer.deliver(user:user, invoice:invoice)
```

### Prepare

The `prepare` method can be used by developers to customize the mail message at the low level.

It gives access to the object `mail` of type `Mail`

It can be used to support attachments, such as in:

```ruby
class SubscriptionMailer
  include Lotus::Mailer

  def prepare
    mail.attachments['invoice.pdf'] = '/path/to/invoice.pdf'
  end
end
```

## Versioning

__Lotus::Mailer__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

---
**This project is part of the [Rails Girls Summer of Code 2015](https://teams.railsgirlssummerofcode.org/teams/66) program.**

**Until the end of September 2015 we only accept contributions made by the students.**
---

## Copyright

Copyright © 2015 Luca Guidi – Released under MIT License


