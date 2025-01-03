# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lolita-i18n/version"

Gem::Specification.new do |s|
  s.name        = "lolita-i18n"
  s.version     = Lolita::I18n::Version.to_s
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["ITHouse (Latvia)", "Arturs Meisters", "Gatis Tomsons"]
  s.email       = "support@ithouse.lv"
  s.homepage    = "http://github.com/ithouse/lolita-i18n"
  s.summary     = %q{Lolita plugin, that enables .yml management}
  s.description = %q{Lolita plugin, that enables .yml files management from administrative interface. Also faster access to translations, that DB store}

  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.licenses = ["MIT"]

  s.add_runtime_dependency(%q<lolita>, [">= 4.5"])
  s.add_runtime_dependency(%q<i18n>, ["~> 1.0"])
  s.add_runtime_dependency(%q<redis>, ["~> 5.0"])
  s.add_runtime_dependency(%q<yajl-ruby>,["~> 1.4"])
  s.add_runtime_dependency(%q<caxlsx>,[">= 4.0"])
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
