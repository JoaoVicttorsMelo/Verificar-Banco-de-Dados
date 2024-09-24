require 'yaml'
require 'tiny_tds'
require 'sqlite3'
require_relative 'enviar_email'

class TamanhoBanco
  include EnviarEmail
  SCRIPT = "EXEC sp_spaceused"

  def initialize(db)
    @db = db
    conectar_banco
  end

  private

  def conectar_banco
    @db = SQLite3::Database.new(@db)
    puts "Conexão efetuada com sucesso"
  rescue SQLite3::Exception => e
    puts "Erro ao conectar: #{e.message}"
  end

  public

  def finalizar_banco
    if @db
      @db.close
      puts "Banco finalizado com sucesso"
    else
      puts "Não existe nenhuma conexão aberta"
    end
  end

  private

  def script_permitido?(script)
    script.strip.downcase.start_with?('exec')
  end

  public

  def verificar_banco
    lojas_banco_cheio = []

    # Carregar configuração do arquivo YAML
    config_path = File.join(__dir__, 'config.yml')
    config = YAML.load_file(config_path)

    # Caminho do banco SQLite
    dp_path = config["database_lite"]["db"]
    db = SQLite3::Database.new(dp_path)

    # Consulta no SQLite para pegar IPs e códigos das filiais
    scripts = db.execute(config["sql"]["script"])

    # Para cada filial (consulta no SQLite), conectar ao SQL Server e executar o script
    scripts.each do |script|
      begin
        # Conectar ao SQL Server para a filial atual
        client = TinyTds::Client.new(
          username: config["database_server"]["username"],
          password: config["database_server"]["password"],
          host: script[0], # IP da filial
          database: script[1] == 102 ? config["database_server"]["database"][1] : config["database_server"]["database"][0], # Seleciona o banco correto
          port: 1433
        )

        # Executar o script `sp_spaceused` no SQL Server
        executar_script_sql_server(client, script[2], lojas_banco_cheio)

      rescue TinyTds::Error => e
        puts "Erro ao conectar na loja #{script[2]} - (#{script[1].to_s.rjust(6, '0')}): #{e.message}"
      end
    end

    # Enviar e-mail apenas se houver lojas com banco cheio
    if lojas_banco_cheio.empty?
      puts "Não há lojas com o banco de dados cheio."
    else
      enviar_email(
        "Lojas com Banco de Dados Cheio",
        'Olá, boa noite, favor verificar lojas com o banco de dados cheios',
        "Tamanhos dos bancos de dados:<br>#{lojas_banco_cheio.join("<br>")}"
      )
    end
  end

  # Executar o script no SQL Server
  private
  def executar_script_sql_server(client, filial, lojas_banco_cheio)
    result = client.execute(SCRIPT)
    result.each do |row|
      # Aqui filtramos o campo `database_size`
      database_size = row["database_size"] # Pega a coluna `database_size`
      if database_size
        begin
          if database_size.to_f >= 9500 #Pega somente lojas com banco de dados maior igual a 9,5GB
            puts "Tamanho do banco de dados: #{database_size.to_f}MB da filial #{filial}"
            # Adiciona a informação da loja ao array
            lojas_banco_cheio << "Filial: #{filial}, Tamanho: #{database_size.to_f}MB"
          end
        rescue TinyTds::Error => e
          puts "Erro ao conectar na loja #{filial}: #{e.message}"
        end
      end
    end
  end
end
