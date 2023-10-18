# frozen_string_literal: true

RSpec.describe Commands::Support::RSpec::Matchers::DefineCommand do

  class DummyCommand < Commands::Command
    attribute :dummy_attr

    def call
      "some value"
    end
  end

  class DummyClassWithCommand
    include Commands::Commander

    command :method_name,
      args: ->(instance) { { dummy_attr: instance } },
      class_name: "DummyCommand"
  end

  subject(:dummy) { DummyClassWithCommand.new }

  it do
    is_expected.to define_command(:method_name)
      .with_args(dummy_attr: dummy)
      .class_name("DummyCommand")
  end

end
