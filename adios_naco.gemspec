lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adios_naco/version'

Gem::Specification.new do |spec|
  spec.name          = "adios_naco"
  spec.version       = AdiosNaco::VERSION
  spec.authors       = ["Beatrice Shackelford"]
  spec.email         = ["beatrice_mae@shackelford.org"]

  spec.summary       = %q{Server for the Adios Nacos iOS Game}
  spec.description   = %q{REST API server which supports Adios Nacos iOS Game}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'sinatra', '~> 1.4.7'
  spec.add_dependency 'data_mapper', '~> 1.2.0'
  spec.add_dependency 'dm-redis-adapter', '~> 0.10.1'
  spec.add_dependency 'json', '~> 1.8.3'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rack-test", "~> 0.6.3"
  spec.add_development_dependency "dm-sqlite-adapter", "~> 1.2.0"
end
