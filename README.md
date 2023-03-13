# Commands

A gem `Commands` tem como objetivo disponibilizar:
  - Uma _classe_ base `Commands::Command` para comandos
  - Um _módulo_ `Commands::Commander` para expor comandos como métodos de instâncias

---

## Desenvolvimento

### Docker

O projeto pode ser configurado via docker. A seguir estão os passos para a configuração:

1. Adicione uma chave privada do git no diretório `.docker/.ssh` para ser copiada para dentro do container
  > Obs.: Caso já tenha uma chave id_rsa no diretório `~/.ssh` de sua máquina, o script, a ser executado nos próximos passos, já irá copiá-lo, automaticamente, para dentro da pasta `.docker/.ssh`

2. Adicionar as seguintes linhas no arquivo `~/.bashrc` ou `~/.bash_profile`

```bash
  export DOCKER_USER_UID=$(id -u)
  export DOCKER_GROUP_GID=$(id -g)
```

3. Na raiz do projeto execute o comando `bin/docker-setup` e toda a configuração do docker será realizada

4. Após executar o comando da etapa anterior, o projeto estará pronto para ser utilizado. Existem no projeto alguns comandos para facilitar o uso no dia-a-dia:

    - `bin/docker-up`: Inicia o container do projeto no modo `--detach` ou `-d`
    - `bin/docker-down`: Interrompe o container do projeto
    - `bin/docker-guard`: Inicia o `guard` para execução dos testes
    - `bin/docker-bash`: Acessa o bash do container
    - `bin/docker-sync`: Sincroniza o projeto novamente

---

## Instalação

### Utilizando a gem

Adicione a seguinte linha no `Gemfile` definindo a branch de release adequada:

```ruby
  gem 'commands', git: 'git@github.com:caiena/commands.rb.git', branch: 'release-0.1'
```
   
Execute o seguinte comando no diretório raiz do projeto Rails:

```
  bundle install
```

---

## Utilização

### Classe Commands::Command

- Utilize a _classe_ `Commands::Command` como _classe_ pai de outra classe desejada:

```ruby
  class Example < Commands::Command
    # resto do código
  end
```

- Implemente o método `call`:

```ruby
  class Example < Commands::Command
    def call
      # implemente a lógica
    end

    # resto do código
  end
```  

- Uma vez que uma _classe_ herda da _classe_ `Commands::Command`, alguns métodos de instância se tornam disponíveis:
  - `success?`
    - Verifica se o comando não teve erros
      ```ruby
        example = Example.new

        example.call

        example.success?
      ```

  - `failure?`
    - Verifica se o comando teve erros
      ```ruby
        example = Example.new

        example.call

        example.failure?
      ```

  - `merge_remote_errors!`
    - Realiza o merge de erros retornados na response HTTP de um remote com os erros do comando prefixando todos os atributos com `remote_`
      ```ruby
        example = Example.new

        # Retorno de alguma API
        # Ex.: { "body" => { "errors" => { "service_order_state" => [{ "error" => "invalid" }] } } }
        response = Remote::Api.call

        example.call

        # Adiciona o erro no comando, adicionando `remote_` no atributo
        # Ex.: errors.add :remote_service_order_state, :invalid
        merged_errors = example.merge_remote_errors!(response.body)
      ```

  - `errors_as_json`
    - Exibe os erros do comando como json
      ```ruby
        example = Example.new

        example.call

        # "#{attr_name}" => [{ error: :"#{error_type}", metadata: value }, ...]
        json_errors = example.errors_as_json
      ```

  - `raise_invalid!`
    - Lança uma exceção `Commands::Command::CommandInvalid`
      ```ruby
        example = Example.new

        # Exceção Commands::Command::CommandInvalid
        example.raise_invalid!
      ```


- A classe `Commands::Command` implementa uma variável de leitura chamada `result` que informa o resultado do processamento do comando:
  ```ruby
    example = Example.new

    example.call

    # Resultado do processamento do comando
    result = example.result
  ```

---

### Módulo Commands::Commander

- Inclua o _módulo_ `Commands::Commander` na classe desejada
  ```ruby
    class Example
      include Commands::Commander
    end
  ```

- Vincule o comando na classe
  ```ruby
    class Example
      include Commands::Commander

      command :my_command,
              args: ->(instance) { { some_param: instance } },
              class_name: "MyNamespace::MyCommand"
    end
  ```

- Utilize o comando definido na classe como método de instância
  ```ruby
    example = Example.new

    # chamando o método call do comando
    example.my_command

    # chamando o método call! do comando
    # Lança uma exceção Commands::Command::CommandInvalid se falhar
    example.my_command!
  ```

- Pode-se passar parâmetros para o comando
  ```ruby
    example = Example.new

    # passando parâmetros
    example.my_command(arg1: 100, arg2: "teste")

    # Lança uma exceção Commands::Command::CommandInvalid se falhar
    example.my_command!(arg1: 100, arg2: "teste")
  ```
</details>

---
