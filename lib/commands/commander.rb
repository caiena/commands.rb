# frozen_string_literal: true

module Commands
  #
  # Permite expor Commands como métodos de instância (:commmand) ou de classe (:class_command)
  #
  # exemplo:
  #   class Deal < ApplicationRecord
  #     include Commands::Commander
  #
  #     command :publish,
  #       args: ->(instance) { { deal: instance } },
  #       class_name: "Deals::PublishCommand"
  #
  #     command :calculate_distance_to,
  #       args: ->(instance) { { origin: instance.coordinates } },
  #       class_name: "Geo::CalculateDistanceCommand"
  #   end
  #
  module Commander
    extend ActiveSupport::Concern

    class_methods do


      #
      # Expõe Command como método de instância
      #
      # exemplo:
      #   class Entry < ApplicationRecord
      #     include Commands::Commander
      #
      #     class_command :publish,
      #       args: ->(instance) { { entry: instance } },
      #       class_name: "Entries::PublishCommand"
      #   end
      #
      #   entry = Entry.find id
      #   entry.publish  # ou entry.publish!
      #
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


      #
      # Expõe Command como método de classe
      #
      # exemplo:
      #   class Entry < ApplicationRecord
      #     include Commands::Commander
      #
      #     class_command :search,
      #       args: ->(klass) { { scope: klass } },
      #       class_name: "Entries::SearchCommand"
      #
      #     class_command :refresh_all,
      #       args: ->(klass) { { scope: klass } },
      #       class_name: "Entries::RefreshAllCommand"
      #   end
      #
      #   Entry.search *args
      #   Entry.refresh_all *args
      #
      def class_command(name, args: nil, class_name: nil)
        command_class = (class_name || name.classify).constantize

        define_singleton_method("#{name}!") do |options = {}|
          base_args = args ? args.call(self) : {}
          cmd_args  = options.merge(base_args)

          command = command_class.new cmd_args
          command.call!

          command
        end

        define_singleton_method(name) do |options = {}|
          base_args = args ? args.call(self) : {}
          cmd_args  = options.merge(base_args)

          command = command_class.new cmd_args
          command.call

          command
        end
      end

    end # class_methods

  end
end
