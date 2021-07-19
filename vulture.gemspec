# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vulture/version'

Gem::Specification.new do |spec|
  spec.name          = 'Vulture'
  spec.version       = Vulture::VERSION
  spec.authors       = ['Heyder']
  spec.email         = ['heyder@devnull']

  spec.summary       = 'Static source code analysis tool using regular expression signatures.'
  spec.description   = 'Static source code analysis tool using regular expression signatures.'
  spec.homepage      = 'https://github.com/heyder/vulture'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/heyder/vulture'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.2.10'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
