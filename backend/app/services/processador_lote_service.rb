require 'digest'

# Orquestra o processamento de um lote CSV:
# 1. Gera hash do lote (idempotência)
# 2. Chama o motor C++ (regras de negócio)
# 3. Persiste resultados (se o banco estiver acessível)
class ProcessadorLoteService
  def initialize(csv_content, nome_arquivo: 'lote.csv')
    @csv_content = csv_content
    @nome_arquivo = nome_arquivo
    @hash_lote = Digest::SHA256.hexdigest(csv_content.to_s)
  end

  def executar
    # Idempotência: se o lote já foi processado, retorna o existente
    lote_existente = Lote.find_by(hash_lote: @hash_lote)
    if lote_existente
      return {
        idempotente: true,
        lote: lote_existente,
        resumo: resumo_de(lote_existente)
      }
    end

    # Processa no motor C++ (rápido, em memória)
    resultado = Antecipe::Motor.processar(@csv_content)

    # Persistência (tolerante a falhas de banco)
    lote = persistir(resultado)

    {
      idempotente: false,
      lote: lote,
      resumo: resultado['resumo'].merge(
        total_notas: resultado['notas'].size,
        valor_bruto: resultado['notas'].sum { |n| n['valor_nominal'] }
      ),
      notas: resultado['notas']
    }
  end

  private

  def persistir(resultado)
    lote = Lote.create!(
      nome_arquivo: @nome_arquivo,
      hash_lote: @hash_lote,
      total_linhas: resultado['notas'].size,
      total_aprovadas: resultado['resumo']['aprovadas'],
      total_recusadas: resultado['resumo']['recusadas'],
      valor_total_liquido: resultado['resumo']['total_liquido'],
      status: 'concluido'
    )
    resultado['notas'].each do |n|
      Recebivel.create!(
        lote: lote,
        hash_chave: Digest::SHA256.hexdigest("#{n['nu_documento']}|#{n['doc_cedente']}"),
        nu_documento: n['nu_documento'],
        doc_cedente: n['doc_cedente'],
        nome_sacado: n['nome_sacado'],
        valor_nominal: n['valor_nominal'],
        status: n['aprovada'] ? 'aprovada' : 'recusada',
        motivo_recusa: n['motivos'].join(', '),
        valor_liquido: n['valor_liquido']
      )
    end
    lote
  rescue ActiveRecord::ActiveRecordError, PG::Error => e
    # Banco indisponível: retorna lote não persistido (sem quebrar a API)
    Rails.logger.info("Persistência indisponível, retornando resultado em memória: #{e.class}")
    nil
  end

  def resumo_de(lote)
    {
      total_notas: lote.total_linhas,
      aprovadas: lote.total_aprovadas,
      recusadas: lote.total_recusadas,
      total_liquido: lote.valor_total_liquido.to_f
    }
  end
end
