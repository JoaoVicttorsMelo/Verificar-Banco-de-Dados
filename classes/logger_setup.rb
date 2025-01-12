require 'logger'
require 'fileutils'
require 'logger'
require 'fileutils'

  class Logger_setup
    attr_reader :logger

    def initialize
      setup_logger
    end

    # Configura o logger para registrar logs no arquivo especificado
    def setup_logger
      project_root = File.expand_path(File.join(__dir__, '..'))  # Define o diretório raiz do projeto
      log_dir = File.join(project_root, 'log')                  # Define o diretório de logs
      @log_file = File.join(log_dir, 'database.log')            # Define o caminho do arquivo de log

      ensure_log_file_exists  # Garante que o arquivo de log exista e seja gravável

      shift_age = 5                            # Define a quantidade de arquivos de log antigos a serem mantidos
      shift_size = converter_mb_para_byte(10)  # Define o tamanho máximo do arquivo de log em bytes

      @logger = Logger.new(@log_file, shift_age, shift_size)  # Inicializa o logger com rotação de arquivos
      @logger.level = Logger::INFO                           # Define o nível de log para INFO
    rescue StandardError => e
      # Em caso de erro na configuração do logger, exibe mensagem no console e usa STDOUT
      puts "Erro ao configurar logger: #{e.message}"
      puts "Stacktrace: #{e.backtrace.join("\n")}"
      @logger = Logger.new(STDOUT)
    end

    # Garante que o arquivo de log exista e seja gravável
    def ensure_log_file_exists
      FileUtils.mkdir_p(File.dirname(@log_file))  # Cria o diretório de log caso não exista

      unless File.exist?(@log_file)
        FileUtils.touch(@log_file)  # Cria o arquivo de log se ele não existir
      end

      # Verifica se o arquivo de log é gravável
      unless File.writable?(@log_file)
        raise "Arquivo de log não é gravável: #{@log_file}"
      end
    end

    # Converte megabytes em bytes
    def converter_mb_para_byte(mb)
      mb * 1024 * 1024
    end
  end
