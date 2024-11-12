require_relative 'tamanho_banco'
require 'yaml'

config_path = File.join(__dir__,'config.yml')
config = YAML.load_file(config_path)
caminho_db = config['database']['db']


obj = TamanhoBanco.new(caminho_db)
obj.verificar_banco