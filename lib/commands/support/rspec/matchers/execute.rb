# frozen_string_literal: true

module Commands
  module Support
    module RSpec
      module Matchers
        #
        # Matcher para garantir execução de comando.
        # Baseada em mocks e spies (rspec-mocks), similar a `expect(...).to receive(:method).with(*args)`
        #
        module Execute
          extend ::RSpec::Matchers::DSL

          # Uso:
          # ```
          # describe "#import" do
          #   subject(:data_load) { ProductDataLoad.new }
          #
          #   it "executes and calls subcommand" do
          #     # sets command spy
          #     expect(SubCommand).to execute.with(*subargs).and_call_original
          #
          #     command = Command.new *args
          #     expect { command.call }.to change { something }
          #   end
          # end
          # ```
          #
          matcher :execute do |*_args|

            match do |command_class|
              raise ArgumentError, <<~MSG.strip unless command_class < ::Commands::Command
                class #{command_class.inspect} is not a Command
              MSG

              @command_class = command_class
              args = instance_variable_defined?("@args") ? @args : any_args
              calls_original = @and_call_original || false

              expect(command_class).to receive(:new)
                .with(*args)
                .and_wrap_original do |method, *arguments|
                  cmd = method.call(*arguments)

                  if calls_original
                    expect(cmd).to receive(:call_original).and_call_original
                  else
                    expect(cmd).to receive(:call_original), "execute command"
                  end

                  cmd
                end
            end


            match_when_negated do |command_class|
              raise ArgumentError, <<~MSG.strip unless command_class < ::Commands::Command
                class #{command_class.inspect} is not a Command
              MSG

              @command_class = command_class
              args = instance_variable_defined?("@args") ? @args : any_args
              calls_original = @and_call_original || false

              expect(command_class).not_to receive(:new)
                .with(*args)
                .and_wrap_original do |m, *arguments|
                  cmd = m.call(*arguments)

                  if calls_original
                    expect(cmd).not_to receive(:call_original).and_call_original
                  else
                    expect(cmd).not_to receive(:call_original)
                  end

                  cmd
                end
            end

            def supports_block_expectations?
              true # or some logic
            end

            chain :with do |*args|
              @args = args
            end

            chain :and_call_original do
              @and_call_original = true
            end


            description do
              <<~ERR.strip
                execute
              ERR
            end

            failure_message do
              <<~ERR.strip
                to have executed
              ERR
            end

            # failure_message_when_negated do ... end

          end

        end
      end
    end
  end
end
