# frozen_string_literal: true

RSpec.describe Commands::Support::RSpec::Matchers::DefineClassCommand do

  class DummyClassCommand < Commands::Command
    attribute :dummy_attr

    def call
      "some value"
    end
  end

  class DummyClassWithClassCommand
    include Commands::Commander

    class_command :method_name,
      args: ->(klass) { { scope: klass } },
      class_name: "DummyClassCommand"
  end

  subject(:dummy) { DummyClassWithClassCommand.new }

  it do
    is_expected.to define_class_command(:method_name)
      .with(scope: DummyClassWithClassCommand)
      .class_name("DummyClassCommand")
  end

end
