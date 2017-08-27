# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'will_support/version'

Gem::Specification.new do |spec|
  spec.name          = 'will_support'
  spec.version       = WillSupport::VERSION
  spec.authors       = ['William Howard']
  spec.email         = ['whoward.tke@gmail.com']

  spec.summary       = 'A collection of ruby modules, objects and refinements that I have found useful over the years'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
