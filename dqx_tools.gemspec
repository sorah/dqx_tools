# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dqx_tools/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Shota Fukumori (sora_h)"]
  gem.email         = ["sorah@tubusu.net"]
  gem.description   = %q{Tools for DQX. Own your risk.}
  gem.summary       = %q{useful tools for DQX. Own your risk.}
  gem.homepage      = "https://github.com/sorah/dqx_tools"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dqx_tools"
  gem.require_paths = ["lib"]
  gem.version       = DqxTools::VERSION

  gem.add_dependency 'mechanize'
  gem.add_dependency 'nokogiri'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'

end
