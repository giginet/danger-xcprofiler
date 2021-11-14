lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcprofiler/gem_version'

Gem::Specification.new do |spec|
  spec.name          = 'danger-xcprofiler'
  spec.version       = DangerXcprofiler::VERSION
  spec.authors       = ['giginet']
  spec.email         = ['giginet.net@gmail.com']
  spec.description   = 'danger plugin for asserting Swift compilation time.'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/giginet/danger-xcprofiler'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'xcprofiler'
  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'

  # General ruby development
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'

  # Testing support
  spec.add_development_dependency 'rspec'

  # Calculating code coverage
  spec.add_development_dependency 'coveralls'

  # Linting code and docs
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'

  # If you want to work on older builds of ruby
  spec.add_development_dependency 'listen', '3.0.7'

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency 'pry'
end
