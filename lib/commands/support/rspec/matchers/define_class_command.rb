# frozen_string_literal: true

module Commands
  module Support
    module RSpec
      module Matchers
        #
        # Matcher que verifica a definição de um comando como método de classe no alvo
        #
        module DefineClassCommand
          extend ::RSpec::Matchers::DSL

          # Uso:
          # ```
          # describe "class commands" do
          #   it do
          #     is_expected.to define_class_command(:search)
          #       .with(scope: described_class)
          #       .class_name("Entries::SearchCommand")
          #   end
          # end
          # ```
          #
          matcher :define_class_command do |method_name|

            match do |record|
              raise ArgumentError, <<~MSG.strip unless @command_class < Commands::Command
                class #{@command_class.inspect} is not a Command
              MSG

              command       = double
              command_class = @command_class

              @record = record

              if @args
                allow(command_class).to receive(:new)
                  .with(*@args)
                  .and_return(command)
              else
                allow(command_class).to receive(:new)
                  .and_return(command)
              end

              allow(command).to receive(:success?).and_return(true)
              allow(command).to receive(:call).and_return("anything")
              allow(command).to receive(:call!).and_return("anything!")

              expect(record.class.send(method_name)).to eq command
              expect(command).to have_received(:call)

              expect(record.class.send("#{method_name}!")).to eq command
              expect(command).to have_received(:call!)
            end

            chain :class_name do |class_name|
              @command_class = class_name.is_a?(String) ? class_name.constantize : class_name
            end

            chain :with do |*args|
              @args = args
            end

            # alias de :with
            chain :with_args do |*args|
              @args = args
            end

            description do
              <<~ERR.strip
                define class method :#{method_name} using #{@command_class.inspect}
              ERR
            end

            failure_message do
              <<~ERR.strip
                expected #{@record} to define class method :#{method_name} using #{@command_class.inspect}
              ERR
            end
          end

        end
      end
    end
  end
end
