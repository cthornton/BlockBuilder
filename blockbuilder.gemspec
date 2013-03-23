# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'block_builder/version'

Gem::Specification.new do |gem|
  gem.name          = "blockbuilder"
  gem.version       = BlockBuilder::VERSION
  gem.authors       = ["Christopher Thornton"]
  gem.email         = ["rmdirbin@gmail.com"]
  gem.description   = %q{Make callbacks easily and build blocks with ease! BlockBuilder is intended to be used with more heavy weight method calls that might require intermediate callbacks. It's almost like creating classes on the fly!}
  gem.summary       = %q{Create complex function callbacks with ease!}
  gem.homepage      = "https://github.com/cgthornt/BlockBuilder"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
