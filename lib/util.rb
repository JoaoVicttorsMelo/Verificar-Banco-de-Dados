require_relative '../classes/logger_setup'
module Util
logger_setup = Logger_setup.new
@logger = logger_setup.logger
@logger.info "Logger inializado com sucesso no modulo util.rb"

  def converter_string_mb_to_gb(str_mb)
    valor_mb = str_mb.split(" ").first.to_f
    (valor_mb / 1024).round(2)  # MB / 1024 = GB (aprox)
  end

  def verifica_horario?
    horario = Time.now       # Obtém o horário atual
    data = Date.today        # Obtém a data atual

    # Filtro para as datas específicas (25/12 e 1/1)
    if (data.day == 25 && data.month == 12) || (data.day == 1 && data.month == 1)
      @logger.warn("Operação não permitida em feriados especiais: Natal (25/12) ou Ano Novo (1/1)")
      return false
    end

    if data.sunday? || data.saturday?      # Se for domingo
      @logger.warn "no dia de hoje (Sabado ou Domingo) o programa não roda"
      false
    else
      if horario.hour >= 18 && horario.hour<=19   # Horário permitido: 18h e menor que as 19h
        @logger.info "Horário Permitido"
        true
      else
        @logger.warn "Fora de horário de funcionamento"     # Mensagem informando fora do horário
        false
      end
    end
  end
end
