# frozen_string_literal: true

require_relative 'lib/challenge/version'

Gem::Specification.new do |spec|
  spec.name = 'challenge'
  spec.version = Challenge::VERSION
  spec.authors = ['Toby C']
  spec.email = ['your.email@example.com']

  spec.summary = 'Client data analysis CLI tool'
  spec.description = 'A Ruby command-line application for searching and analyzing client data from JSON datasets'
  spec.homepage = 'https://github.com/tob1k/challenge'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}.git"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['github_repo'] = 'ssh://github.com/tob1k/challenge'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ example/ .git .github .rspec .rubocop.yml Gemfile Gemfile.lock])
    end
  end
  spec.bindir = 'bin'
  spec.executables = ['challenge']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'csv', '~> 3.0'
  spec.add_dependency 'thor', '~> 1.0'
end
