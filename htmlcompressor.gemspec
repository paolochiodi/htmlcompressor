# -*- encoding: utf-8 -*-
require File.expand_path('../lib/htmlcompressor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paolo Chiodi"]
  gem.email         = ["chiodi84@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.add_dependency 'yui-compressor', '~> 0.9.6'
  gem.add_development_dependency 'closure-compiler', '~> 1.1.5'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "htmlcompressor"
  gem.require_paths = ["lib"]
  gem.version       = Htmlcompressor::VERSION
end
