# frozen_string_literal: true

require "commands"
require "commands/support/rspec/matchers"

RSpec.configure do |config|
  config.include Commands::Support::RSpec::Matchers::DefineCommand
  config.include Commands::Support::RSpec::Matchers::DefineClassCommand
  config.include Commands::Support::RSpec::Matchers::Execute

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
