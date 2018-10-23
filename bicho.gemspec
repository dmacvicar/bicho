# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'bicho/version'

Gem::Specification.new do |s|
  s.name        = 'bicho'
  s.version     = Bicho::VERSION
  s.authors     = ['Duncan Mac-Vicar P.']
  s.email       = ['dmacvicar@suse.de']
  s.homepage    = 'http://github.com/dmacvicar/bicho'
  s.summary     = 'Library to access bugzilla'
  s.description = 'Library to access bugzilla'
  s.licenses    = ['MIT']

  s.add_dependency('inifile', ['~> 3.0.0'])
  s.add_dependency('trollop', ['~> 2.1.2'])
  s.add_dependency('highline', ['~> 1.7.8'])
  s.add_dependency('nokogiri', ['~> 1.8.1'])
  s.add_dependency('xmlrpc', ['~> 0.3.0'])

  s.add_development_dependency('rake')
  s.add_development_dependency('minitest')
  s.add_development_dependency('minitest-reporters')
  s.add_development_dependency('rubocop', '= 0.41.2')
  s.add_development_dependency('vcr')
  s.add_development_dependency('webmock')

  s.rubyforge_project = 'bicho'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.3'
end
