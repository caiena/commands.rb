# frozen_string_literal: true

require_relative "lib/commands/version"

Gem::Specification.new do |spec|
  spec.name = "commands"
  spec.version = Commands::VERSION
  spec.authors = ["Caiena"]
  spec.email   = [""]

  spec.summary = "Commands"
  spec.description = "Funcionalidades básicas de comando"
  spec.homepage = "https://caiena.net/"
  spec.required_ruby_version = ">= 3.2.1"

  spec.metadata["allowed_push_host"] = ""

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/caiena/commands.rb"
  spec.metadata["changelog_uri"] = "https://github.com/caiena/commands.rb"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "appraisal"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
