require 'yaml'
require 'tiny_tds'
require 'sqlite3'
require_relative '../lib/enviar_email'
require_relative '../lib/util'
require_relative 'logger_setup'
require_relative 'filial_ip'          # Modelo para acessar a tabela filiais_ip
require_relative '../lib/conexao_banco'  # Módulo para gerenciar a conexão com o banco de dados

class Services
  attr_accessor :db
  include EnviarEmail
  include ConexaoBanco
  include Util

  TAMANHO_BD = 8.5

  def initialize(db)
    logger_setup = Logger_setup.new
    @logger = logger_setup.logger
    @logger.info "Logger inializado com sucesso no arquivo services.rb"
    @db = db
  end

  private

  # Abre a conexão com o banco de dados SQLite
  def abrir_conexao_banco_lite
    ConexaoBanco.parametros(@db)           # Configura os parâmetros de conexão
    @logger.info "Conexão estabelecida com sucesso"  # Log de conexão bem-sucedida
  rescue SQLite3::Exception => e
    @logger.error "Erro ao abrir conexão: #{e.message}"  # Log de erro na conexão
    retry_connection(e)  # Tenta reconectar em caso de erro
  end

  # Exemplo simples de como definir o método de "tentativa de reconexão".
  def retry_connection(error)
    @logger.warn "Tentando reconexão após erro: #{error.message}"
    sleep 3
    abrir_conexao_banco_lite
  end

  public

  def finalizar_banco
    if @db
      @db.close
      @logger.info "Banco finalizado com sucesso"
    else
      @logger.error "Não existe nenhuma conexão aberta"
    end
  end

  public

  def conectar_banco_server_loja(ip, cod_filial, filial)
    begin
      config = conectar_yml  # Carrega as configurações do arquivo YAML
      TinyTds::Client.new(
        username: config["database_server"]["username"],
        password: config["database_server"]["password"],
        host: ip,
        database: cod_filial == 102 ? config["database_server"]["database"][1] : config["database_server"]["database"][0],
        port: 1433
      )
    rescue TinyTds::Error => e
      @logger.error "Não foi possivel conectar no banco da loja: #{e.message}"  # Log de erro na conexão
      nil  # Retorna nil em caso de falha na conexão
    end
  end

  private

  def script_permitido?(script)
    # Verifica se o script começa com "exec"
    script.strip.downcase.start_with?('exec')
  end

  public

  def verificar_banco
    if verifica_horario?
    abrir_conexao_banco_lite  # <- Assumindo que esse método abra a conexão @db do SQLite
      lojas_banco_cheio = []

      # Carregar configuração do arquivo YAML
      config_path = File.join(__dir__, '..', 'config.yml')
      config = YAML.load_file(config_path)

      lista_offline = config['offline']['filial']
      ips = FiliaisIp.where(servidor: 1).where.not(cod_filial: lista_offline)
                     .select(:ip, :filial, :cod_filial)
                     .order(:cod_filial)

      # Exemplo de script que você pode querer rodar em cada filial
      sql_command = "EXEC sp_spaceused"

      # Para cada IP, conectar e verificar tamanho do banco
      ips.each do |f|
        ip         = f.IP
        filial     = f.FILIAL
        cod_filial = f.COD_FILIAL

        client_loja = conectar_banco_server_loja(ip, cod_filial, filial)
        if client_loja
          executar_script_sql_server(client_loja, filial, cod_filial, lojas_banco_cheio, sql_command)
          client_loja.close
        end
      end

      # Exemplo de pegar scripts customizados do SQLite (se necessário)
      scripts_sqlite = @db.execute(config["sql"]["script"])  # Retorna array com [ip, cod_filial, nome_filial, ...?]

      scripts_sqlite.each do |arr|
        begin
          ip_script     = arr[0]
          cod_filial_db = arr[1]
          filial_db     = arr[2]

          client = TinyTds::Client.new(
            username: config["database_server"]["username"],
            password: config["database_server"]["password"],
            host: ip_script,
            database: cod_filial_db == 102 ? config["database_server"]["database"][1] : config["database_server"]["database"][0],
            port: 1433
          )

          executar_script_sql_server(client, filial_db, cod_filial_db, lojas_banco_cheio, sql_command)
          client.close
        rescue TinyTds::Error => e
          @logger.error "Erro ao conectar na loja #{filial_db} - (#{cod_filial_db.to_s.rjust(6, '0')}): #{e.message}"
        end
      end

      finalizar_banco

      # Enviar e-mail apenas se houver lojas com banco cheio
      if lojas_banco_cheio.empty?
        @logger.info "Não há lojas com o banco de dados cheio."
      else
        enviar_email(
          titulo: "Lojas com Banco de Dados Cheio",
          corpo: "Favor verificar lojas com o banco de dados cheios",
          informacao: "Tamanhos dos bancos de dados:<br>#{lojas_banco_cheio.join("<br>")}"
        )
      end
      end
  end

  # Executar o script no SQL Server
  def executar_script_sql_server(client, filial, codigo, lojas_banco_cheio, sql_command)
    # Aqui verificamos se o script é permitido
    if script_permitido?(sql_command)
      result = client.execute(sql_command)
      result.each do |row|
        # Filtramos o campo `database_size`
        database_size = row["database_size"]  # Pega a coluna `database_size`
        if database_size
          begin
            database_gb = converter_string_mb_to_gb(database_size)
            if database_gb.to_f >= TAMANHO_BD
              @logger.info "Tamanho do banco de dados: #{database_gb.to_f} GB da filial #{filial} (#{codigo.to_s.rjust(6, '0')})"
              lojas_banco_cheio << "Filial: #{filial} (#{codigo.to_s.rjust(6, '0')}), Tamanho: #{database_gb.to_f} GB"
            end
          rescue TinyTds::Error => e
            @logger.error "Erro ao conectar na loja #{filial}: #{e.message}"
          end
        end
      end
    else
      @logger.warn "Script não permitido: #{sql_command}"
    end
  end

  # Carrega as configurações do arquivo YAML
  def conectar_yml
    config_path = File.expand_path('../config.yml', __dir__)  # Define o caminho do arquivo de configuração
    YAML.load_file(config_path)  # Carrega e retorna o conteúdo do arquivo YAML
  end
  end