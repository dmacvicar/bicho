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

  s.add_dependency('inifile', ['~> 0.4.1'])
  s.add_dependency('trollop', ['>= 1.16'])
  s.add_dependency('highline', ['~> 1.6.2'])
  s.add_dependency('nokogiri')

  s.add_development_dependency('rake')
  s.add_development_dependency('minitest')
  s.add_development_dependency('minitest-reporters')

  s.rubyforge_project = 'bicho'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 1.9.3'
end
