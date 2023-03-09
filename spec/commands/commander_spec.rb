# frozen_string_literal: true

require "./lib/commands/commander"

RSpec.describe Commands::Commander do
  describe "methods" do
    describe "command" do
      class ExampleCommand < Commands::Command
        attribute :attr1

        def call
          "some value"
        end
      end

      class ExampleKlass
        include Commands::Commander

        command :example_command,
                args: ->(instance) { { attr1: instance } },
                class_name: "ExampleCommand"
      end

      let(:example_klass) { ExampleKlass.new }

      describe "methods" do
        it "exposes commands as instance methods with bang" do
          expect(example_klass).to respond_to(:example_command!)
        end

        it "exposes commands as instance methods without bang" do
          expect(example_klass).to respond_to(:example_command)
        end
      end

      describe "method calls" do
        describe "method with bang (!)" do
          let(:example_command) { example_klass.example_command! }

          it "passes arguments to command" do
            expect(example_command.attr1).to eq(example_klass)
          end

          it "returns a command instance" do
            expect(example_command).to be_a(ExampleCommand)
          end

          it "executes command`s call!" do
            allow_any_instance_of(ExampleCommand).to receive(:call!)

            expect(example_command).to have_received(:call!)
          end
        end

        describe "method without bang (!)" do
          let(:example_command) { example_klass.example_command }

          it "passes arguments to command" do
            expect(example_command.attr1).to eq(example_klass)
          end

          it "returns a command instance" do
            expect(example_command).to be_a(ExampleCommand)
          end

          it "executes command`s call" do
            allow_any_instance_of(ExampleCommand).to receive(:call)

            expect(example_command).to have_received(:call)
          end
        end
      end
    end
  end
end
