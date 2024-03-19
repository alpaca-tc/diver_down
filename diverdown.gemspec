# frozen_string_literal: true

require_relative 'lib/diverdown/version'

Gem::Specification.new do |spec|
  spec.name = 'diverdown'
  spec.version = Diverdown::VERSION
  spec.authors = ['alpaca-tc']
  spec.email = ['alpaca-tc@alpaca.tc']

  spec.summary = 'Tool to dynamically analyze applications and create dependency maps'
  spec.description = ''
  spec.homepage = 'https://github.com/alpaca-tc/diverdown'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = []
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'msgpack'
  spec.add_dependency 'rackup'
end
