# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in commands.gemspec
gemspec

gem "rake", "~> 13.0"

gem "rubocop", "~> 1.21"

gem "activemodel", "~> 6.0"

group :development do
  gem "appraisal"
end

group :development, :test do
  gem "rspec", "~> 3.0"
  gem "guard-rspec", require: false
end
