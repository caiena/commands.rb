# frozen_string_literal: true

require "active_model"

module Commands
  
  # Classe base para Commands
  class Command
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    class Error < StandardError; end

    # Classe que expoe um erro padrão
    #
    class CommandInvalid < Error
      attr_reader :command

      def initialize(command = nil)
        @command = command

        msg = "Could not execute command (#{command.inspect})."
        msg += " (errors: #{command.errors.inspect})"

        super msg
      end
    end

    # Criando um hook para interceptar a definição/implementação do método :call na classe
    # Command, guardando seu retorno em @result.
    #
    # ref: https://stackoverflow.com/a/7137362
    def self.method_added(method_name)
      return unless method_name == :call
      return if @__last_methods_added&.include? method_name

      overriden_method_name  = :"#{method_name}_overriden"
      original_method_name   = :"#{method_name}_original"
      @__last_methods_added  = [method_name, overriden_method_name, original_method_name]

      define_method(overriden_method_name) do |*args, &block|
        return nil unless valid?

        @result = send(original_method_name, *args, &block)
      end
      alias_method original_method_name, method_name
      alias_method method_name,          overriden_method_name

      @__last_methods_added = nil
    end

    attr_reader :result

    # command API - SpecialCommand.call(*args)
    def self.call(*args)
      new(*args).call
    end

    def self.call!(*args)
      new(*args).call!
    end

    # XXX: Copiado de ApplicationModel
    # @override
    # Ignorando atributos desconhecidos, para "flexibilizar" o consumo de apis com dados extras
    # ref: https://github.com/rails/rails/blob/83217025a171593547d1268651b446d3533e2019/activemodel/lib/active_model/model.rb#L80
    def initialize(attrs = {})
      # XXX: para sobrecarregar, precisamos replicar essa linha abaixo para que os atributos estejam carregados!
      # - ref: https://github.com/rails/rails/blob/83217025a171593547d1268651b446d3533e2019/activemodel/lib/active_model/attributes.rb#L75-L78
      @attributes = self.class._default_attributes.deep_dup

      # aqui filtramos apenas os atributos/writers conhecidos, ignorando eventuais dados "extras"
      # - se uma API passar a responder um atributo a mais, nossos models não vão lançar UnknownAttributeError!
      known_attrs = (attrs || {}).select do |attr_name, _attr_value|
        respond_to? :"#{attr_name}="
      end

      super(known_attrs)
    end

    def call
      raise NotImplementedError
    end

    def call!
      return_value = call
      raise_invalid! if failure?

      return_value
    end

    def success?
      errors.blank?
    end

    def failure?
      !success?
    end

    # predicate methods for attributes, like ActiveRecord.
    # - e.g. user.active?  # => true if user.active == true
    attribute_method_suffix "?"

    # XXX: permitindo erros em "attributes" não existentes
    # ref: https://github.com/rails/rails/issues/28810
    # ref: https://github.com/AaronLasseigne/active_interaction/issues/451
    def read_attribute_for_validation(attr)
      respond_to?(attr, true) ? send(attr) : attr
    end

    # XXX: faz merge de erros retornados na response HTTP do remote com os erros do comando,
    # prefixando todos os atributos com "remote_".
    #
    # exemplo:
    # - response.body == { "errors" => { "service_order_state" => [{ "error" => "invalid" }] } }
    # - erros adicionados: `errors.add :remote_service_order_state, :invalid`
    #
    # TODO: acompanhar reuso e entender para onde mover esse método utilitário
    def merge_remote_errors!(response)
      response_data = response.respond_to?(:data) ? response.data : response.body
      response_errors = begin
        response_data.respond_to?(:[]) ? response_data["errors"] : nil
      rescue StandardError
        nil
      end
      return if response_errors.blank?

      merge_error = lambda do |attr_name, err|
        case err
        when Hash
          error_code = err["error"]
          errors.add :"remote_#{attr_name}", error_code.to_sym
        when String
          error_code = err
          errors.add :"remote_#{attr_name}", error_code.to_sym
        end
      end

      # sample: expect(response_data["errors"]).to include "service_order_state" => [{ "error" => "invalid" }]
      # sample: expect(response_data["errors"]).to include "service_order" => ["invalid", "custom_error"]
      # sample: expect(response_data["errors"]).to include "service_order" => "invalid"
      response_errors.each_key do |attr_name|
        # XXX: E se o response estiver definido como "data"?
        attr_errors = response.body.dig("errors", attr_name)

        Array(attr_errors).each { |err| merge_error.call attr_name, err }
      end
    end

    def errors_as_json
      # "#{attr_name}" => [{ error: :"#{error_type}", metadata: value }, ...]
      errors.group_by(&:attribute).transform_values do |errs|
        errs.map(&:details)
      end
    end

    def raise_invalid!
      raise CommandInvalid, self
    end

    protected

    def logger
      @logger ||= Rails.logger
    end

    private

    def attribute?(attribute)
      send(attribute).present?
    end

    #
    # Facilitando o uso de transações - delegando ao ApplicationRecord.
    #
    # :reek:UtilityFunction
    def transaction(*args, **options, &block)
      # por padrão, transações em commands serão marcadas como "real sub-transactions"
      # ref: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#module-ActiveRecord::Transactions::ClassMethods-label-Nested+transactions
      options[:requires_new] = true unless options.key? :requires_new

      ApplicationRecord.transaction(*args, **options, &block)
    end
  end
end
