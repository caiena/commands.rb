# frozen_string_literal: true

module Commands
  # Permite expor Commands como métodos de instância
  #
  # exemplo:
  # class Deal < ApplicationRecord
  #   include Commander
  #
  #   command :publish,
  #     args: ->(instance) { { deal: instance } },
  #     class_name: "Deals::PublishCommand"
  #
  #   command :calculate_distance_to,
  #     args: ->(instance) { { origin: instance.coordinates } },
  #     class_name: "Geo::CalculateDistanceCommand"
  # end
  #
  module Commander
    extend ActiveSupport::Concern

    class_methods do
      def command(name, args: nil, class_name: nil)
        command_class = (class_name || name.classify).constantize

        define_method("#{name}!") do |options = {}|
          base_args = args ? args.call(self) : {}
          cmd_args  = options.merge(base_args)

          command = command_class.new cmd_args
          command.call!

          command
        end

        define_method(name) do |options = {}|
          base_args = args ? args.call(self) : {}
          cmd_args  = options.merge(base_args)

          command = command_class.new cmd_args
          command.call

          command
        end
      end
    end
  end
end
