require 'yaml'
require 'tiny_tds'
require 'sqlite3'
require_relative 'enviar_email'

class TamanhoBanco
  include EnviarEmail
  SCRIPT = "EXEC sp_spaceused"
  TAMANHO_BD=8.5

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
    dp_path = config["database"]["db"]
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
        executar_script_sql_server(client, script[2],script[1], lojas_banco_cheio)

      rescue TinyTds::Error => e
        puts "Erro ao conectar na loja #{script[2]} - (#{script[1].to_s.rjust(6, '0')}): #{e.message}"
      end
    end

    # Enviar e-mail apenas se houver lojas com banco cheio
    if lojas_banco_cheio.empty?
      puts "Não há lojas com o banco de dados cheio."
    else
      enviar_email(
        titulo: "Lojas com Banco de Dados Cheio",
        corpo: "Olá,#{apresentacao(Time.now.hour)}, favor verificar lojas com o banco de dados cheios",
        informacao: "Tamanhos dos bancos de dados:<br>#{lojas_banco_cheio.join("<br>")}"
      )
    end
  end

  # Executar o script no SQL Server
  private
  def executar_script_sql_server(client, filial,codigo, lojas_banco_cheio)
    if script_permitido?(SCRIPT)
      result = client.execute(SCRIPT)
      result.each do |row|
        # Aqui filtramos o campo `database_size`
        database_size = row["reserved"] # Pega a coluna `database_size`
        if database_size
          begin
            database_gb = converter_kb_to_gb(database_size)
            if database_gb.to_f >= TAMANHO_BD #Pega somente lojas com banco de dados maior igual a 9,5GB
              puts "Tamanho do banco de dados: #{database_gb.to_f} GB da filial #{filial} (#{codigo.to_s.rjust(6, '0')})"
              # Adiciona a informação da loja ao array
              lojas_banco_cheio << "Filial: #{filial} (#{codigo.to_s.rjust(6, '0')}), Tamanho: #{database_gb.to_f} GB"
            end
          rescue TinyTds::Error => e
            puts "Erro ao conectar na loja #{filial}: #{e.message}"
          end
        end
      end
    end

  end

  def converter_kb_to_gb(kb)
    gb = kb.to_f / 1_048_576
    return gb.round(2)  # Arredonda para 2 casas decimais
  end

  def apresentacao(hora)
    case hora
    when 10..11 then "Bom dia"
    when 12..17 then "Boa tarde"
    else "Boa noite"
    end
  end

end
