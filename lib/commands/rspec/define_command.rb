# frozen_string_literal: true

#
# Validação garantindo que o command pode ser invocado.
#
module DefineCommand
  extend RSpec::Matchers::DSL

  # Uso:
  # ```
  # describe "#import" do
  #   subject(:data_load) { ProductDataLoad.new }
  #
  #   it do
  #     is_expected.to define_command(:import)
  #       .with_args(data_load: data_load)
  #       .class_name("DealProducts::DataLoadImportCommand")
  #   end
  # end
  # ```
  #
  matcher :define_command do |method_name|

    match do |record|
      raise ArgumentError, <<~MSG.strip unless @command_class < Commands::Command
        class #{@command_class.inspect} is not a Command
      MSG

      command       = double
      args          = @args || []
      command_class = @command_class

      allow(command_class).to receive(:new)
        .with(*args).and_return(command)

      allow(command).to receive(:success?).and_return(true)
      allow(command).to receive(:call).and_return("anything")
      allow(command).to receive(:call!).and_return("anything!")

      expect(record.send(method_name)).to eq command
      expect(command).to have_received(:call)

      expect(record.send("#{method_name}!")).to eq command
      expect(command).to have_received(:call!)
    end

    chain :class_name do |class_name|
      @command_class = class_name.is_a?(String) ? class_name.constantize : class_name
    end

    chain :with do |*args|
      @args = args
    end

    chain :with_args do |*args|
      @args = args
    end


    description do
      <<~ERR.strip
        define method :#{method_name} for #{@command_class.inspect}
      ERR
    end

    failure_message do
      <<~ERR.strip
        expected #{record} to define method :#{method_name} for #{@command_class.inspect}
      ERR
    end
  end
end
