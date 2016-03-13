# Bicho

* http://github.com/dmacvicar/bicho

![stable](https://img.shields.io/badge/stability-stable-green.svg)
![maintained](https://img.shields.io/maintenance/yes/2016.svg)

## Introduction

Library to access bugzilla and command line tool.

Its main goal is to be clean and provide a command line tool
that exposes its features.

## Features

Main use case is report generation, therefore only the following
features are implemented right now:

* get bugs
* search bugs

Plugins can be written to deal with specific bugzilla installations.

## Example (API)

### Client API

```ruby
require 'bicho'

server = Bicho::Client.new('http://bugzilla.gnome.org')
server.get_bugs(127043).each do |bug|
  puts bug.summary
  puts bug.url

  puts bug.history
end
```

You can give more than one bug or a named query, or both:

```ruby
server.get_bugs(127043, 432423) => [....]
server.get_bugs("Named list") => [....]
server.get_bugs("Named list", 4423443) => [....]
```

### ActiveRecord-like API

To use the ActiveRecord like interface over the +Bug+ class, you need first
to set the Bicho common client:

```ruby
require 'bicho'

Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')

Bicho::Bug.where(product: 'vala', status: 'resolved').each do |bug|
  # .. do something with bug
end
```

Or alternatively:

```ruby
Bicho::Bug.where.product('vala').status('resolved').each do |bug|
  # .. do something with bug
end
```

## Example (CLI)

```console
bicho -b http://bugzilla.gnome.org show 127043

bicho -b gnome history 127043

bicho -b gnome search --summary "crash"

bicho -b gnome search --help
```

## Authentication

For SUSE/Novell Bugzilla, a plugin loads the credentials from '~/.oscrc'.

Otherwise, use the 'username:password@' part of the API URL.

## Customizing Bicho: the user.rb plugin.

Plugins are included that provide shortcuts for the most common bugzilla sites.

There is a "user" plugin that does some of these shortcuts from a configuration file.

The settings are read from '.config/bicho/config.yml'. There you can specify the default
bugzilla site to use when none is specified and custom aliases.

```yml
aliases:
    mysite: http://bugzilla.site.com
default: mysite
```

## Extending Bicho

### Plugins

Plugins are classes in the module Bicho::Plugins. They can implement hooks that are
called at different points of execution.

* default_site_url_hook

  If no site url is provided the last one provided by a plugin will be used.

* transform_site_url_hook

  This hook is called to modify the main site url (eg: http://bugzilla.suse.com).
  Use it when a plugin wants to provide an alternative url to a well-known bugzilla or
  a shortcut (eg: bnc) that will be expanded into a site url.
  Plugin order is not defined so make sure your plugin focuses in one type of shortcut
  as another plugin can also change your returned value in their hooks.

* transform_api_url_hook

  The API url is derived from the site url, however some bugzilla installations may have
  different servers or endpoints.

### Commands

See the +Command+ class to implement more commands.

## Known issues

* For now bugs respond to the bugs attributtes described in
http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html, I intend to make those real attributes.
* There is no check if an API is supported on the server side

## Roadmap

* Define the plugin hooks, right now there is one :-)
* Shortcuts for the bugzilla URL (bicho -b bko search ..), a plugin?

## Authors

* Duncan Mac-Vicar P. <dmacvicar@suse.de>

## License

Copyright (c) 2011-2015 SUSE LLC

Bicho is licensed under the MIT license. See MIT-LICENSE for details.
