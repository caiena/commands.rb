# frozen_string_literal: true

require "./lib/commands/commander"

RSpec.describe Commands::Commander do

  describe "command" do

    class DummyTestCommand < Commands::Command
      attribute :attr1

      def call
        "some value"
      end
    end

    class ResourceTestClass
      include Commands::Commander

      command :run,
        args: ->(instance) { { attr1: instance } },
        class_name: "DummyTestCommand"
    end

    let(:resource) { ResourceTestClass.new }


    describe "methods" do
      it "exposes commands as instance methods with bang" do
        expect(resource).to respond_to(:run!)
      end

      it "exposes commands as instance methods without bang" do
        expect(resource).to respond_to(:run)
      end
    end

    describe "method calls" do
      describe "method with bang (!)" do
        let(:run) { resource.run! }

        it "passes arguments to command" do
          expect(run.attr1).to eq(resource)
        end

        it "returns a command instance" do
          expect(run).to be_a(DummyTestCommand)
        end

        it "executes command`s call!" do
          allow_any_instance_of(DummyTestCommand).to receive(:call!)

          expect(run).to have_received(:call!)
        end
      end

      describe "method without bang (!)" do
        let(:run) { resource.run }

        it "passes arguments to command" do
          expect(run.attr1).to eq(resource)
        end

        it "returns a command instance" do
          expect(run).to be_a(DummyTestCommand)
        end

        it "executes command`s call" do
          allow_any_instance_of(DummyTestCommand).to receive(:call)

          expect(run).to have_received(:call)
        end
      end
    end

  end

end
