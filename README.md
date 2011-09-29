= About

Lolita I18n is Lolita[https://github.com/ithouse/lolita] plugin, that enables .yml file translation from WEB interface.

== Usage

- setup rails 3.1 project with ["Lolita"](https://github.com/ithouse/lolita)
- setup [Redis DB](http://redis.io) on your server
- add `gem 'lolita-i18n'` into Gemfile
- add `I18n.backend = Lolita::I18n.load Redis.new` into your `config/initializers/lolita.rb`
- open `/lolita/i18n` and start translating

== Contributing to lolita-i18n
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2011 ITHouse (Latvia). See LICENSE.txt for
further details.