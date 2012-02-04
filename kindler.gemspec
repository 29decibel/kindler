# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kindler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["dongbin.li"]
  gem.email         = ["mike.d.1984@gmail.com"]
  gem.description   = %q{kindler is a rubygem allow you to generate kindle mobi book very easily}
  gem.summary       = %q{kindler is a rubygem allow you to generate kindle mobi book very easily}
  gem.homepage      = "https://github.com/29decibel/kindler"

	gem.rubyforge_project = "kindler"

	gem.add_dependency 'nokogiri'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "kindler"
  gem.require_paths = ["lib"]
  gem.version       = Kindler::VERSION
end
