# frozen_string_literal: true

RSpec.describe Commands::Command do
  let(:command_options) do
    { attr1: 1, attr2: "" }
  end

  let(:command) do
    class ExampleCommand < Commands::Command
      attr_reader :attr1, :attr2

      def call
        "some value"
      end
    end

    ExampleCommand.new command_options
  end

  let(:command_with_error) do
    class ExampleCommand < Commands::Command
      attr_reader :attr1, :attr2

      def call
        errors.add :attr1, "error message"
        "some value"
      end
    end

    ExampleCommand.new command_options
  end

  let(:command_without_call) { described_class.new command_options }

  describe "initialize" do
    context "when command does not respond to attribute" do
      it "ignores the attribute" do
        command = described_class.new(attr1: 1, attr2: 2, attr3: 3)

        expect{ command.attr3}.to raise_error{ NoMethodError }
      end
    end
  end

  describe "methods" do
    describe "call" do
      subject(:call) { command.call }

      context "when call is not overridden" do
        # @override
        let(:command) { command_without_call }

        it "raises NotImplementedError Exception" do
          expect{ call }.to raise_error{ NotImplementedError}
        end
      end

      context "when call is overridden" do
        let(:call_result) { "some value" }

        it "raises NotImplementedError Exception" do
          expect{ call }.not_to raise_error{ NotImplementedError}
        end

        describe "hooks" do
          describe "method_added" do
            it "adds result`s call on result attribute" do
              call

              expect(command.result).to eq call_result
            end
          end
        end
      end
    end

    describe "call!" do
      subject(:call!) { command.call! }

      context "when call is not overriden" do
        # @override
        let(:command) { command_without_call }

        it "raises NotImplementedError Exception" do
          expect{ call! }.to raise_error{ NotImplementedError}
        end
      end

      context "when command has errors" do
        before do
          allow_any_instance_of(Commands::Command).to receive(:failure?).and_return(true)
        end

        it "raises CommandInvalid Exception" do
          expect{ call! }.to raise_error{ Commands::Command::CommandInvalid }
        end
      end

      context "when command does not have errors" do
        let(:call_result) { "some value" }

        it { expect{ call! }.not_to raise_error{ NotImplementedError} }

        describe "hooks" do
          describe "method_added" do
            it "adds result`s call on result attribute" do
              call!

              expect(command.result).to eq call_result
            end
          end
        end
      end
    end

    describe "success?" do
      subject(:success?) { command.success? }

      before { command.call }

      context "when there are errors" do
        # @override
        let(:command) { command_with_error }

        it { expect(success?).to be_falsy }
      end

      context "when there is no error" do
        it { expect(success?).to be_truthy }
      end
    end

    describe "failure?" do
      subject(:failure?) { command.failure? }

      before { command.call }

      context "when there are errors" do
        # @override
        let(:command) { command_with_error }

        it { expect(failure?).to be_truthy }
      end

      context "when there is no error" do
        it { expect(failure?).to be_falsy }
      end
    end

    # override
    describe "read_attribute_for_validation" do
      subject(:read_attribute_for_validation) do
        command.read_attribute_for_validation(attribute)
      end

      let(:attribute) { command_options.keys.sample }

      before { command.call }

      context "when attribute does not exist" do
        let(:attribute) { :another_attr }

        it { expect(read_attribute_for_validation).to eq(:another_attr) }
      end

      context "when attribute exists" do
        it { expect(read_attribute_for_validation).to eq(command.attr1) }
      end
    end

    describe "merge_remote_errors!" do
      context "when response has body key" do
        let(:response_data) do
          double(:response, body: {
            "errors" => {
              "field_name_1" => [
                { "error" => "invalid" }
              ],
            }
          })
        end

        context "and response has `errors` key" do
          it "includes remote_ on attribute name" do
            command.merge_remote_errors!(response_data)

            expect(command.errors).to include(:remote_field_name_1)
          end
        end

        context "and response does not have `errors` key" do
          let(:response_data) do
            double(:response, body: {})
          end

          it "does not include remote_ on attribute name" do
            command.merge_remote_errors!(response_data)

            expect(command.errors).not_to include(:remote_field_name_1)
          end
        end
      end
    end

    describe "errors_as_json" do
      # @override
      let(:command) { command_with_error }
      let(:expected_result) do
        { :attr1 => [{ :error => "error message" }]}
      end

      it "transforms errors as json" do
        command.call

        expect(command.errors_as_json).to eq(expected_result)
      end
    end

    describe "raise_invalid!" do
      it "raises CommandInvalid Exception" do
        expect{ command.raise_invalid! }.to raise_error{ Commands::Command::CommandInvalid }
      end
    end
  end

end
