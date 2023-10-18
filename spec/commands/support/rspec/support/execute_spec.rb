# frozen_string_literal: true

RSpec.describe Commands::Support::RSpec::Matchers::Execute do

  class DummyExecuteCommand < Commands::Command
    attribute :dummy_attr

    def call
      "some value"
    end
  end

  class DummyClassWithExecuteCommand
    include Commands::Commander

    command :execute,
      args: ->(instance) { { source: instance } },
      class_name: "DummyExecuteCommand"
  end

  subject(:dummy) { DummyClassWithExecuteCommand.new }


  it "executes and calls subcommand" do
    # sets command spy
    expect(DummyExecuteCommand).to execute.with(source: dummy).and_call_original

    dummy.execute
  end

end
