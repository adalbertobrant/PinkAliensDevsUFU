require 'csv'
require 'digest'
require 'set'

# Converte data dd/mm/aaaa em Date (retorna nil se vazia/inválida)
def parse_data_br(str)
  s = str.to_s.strip
  return nil if s.empty?
  Date.strptime(s, '%d/%m/%Y')
rescue Date::Error
  nil
end

namespace :antecipe do
  desc 'Importa estoque historico do estoque_antecipe.csv (inserção em lote)'
  task import_estoque: :environment do
    arquivo = Rails.root.join('..', 'arquivos', 'estoque_antecipe.csv')
    puts "Importando de #{arquivo}"

    # Carrega os hashes já existentes (idempotência) em um Set
    existentes = Set.new(Estoque.pluck(:hash_chave))
    puts "Registros já existentes: #{existentes.size}"

    agora = Time.current
    registros = []
    contador = 0
    BATCH_SIZE = 10_000

    CSV.foreach(arquivo, col_sep: ';', headers: true, encoding: 'UTF-8') do |row|
      nu_documento = row['NU_DOCUMENTO'].to_s.strip
      doc_cedente = row['DOC_CEDENTE'].to_s.strip
      hash_chave = Digest::SHA256.hexdigest("#{nu_documento}|#{doc_cedente}")

      # Pula duplicados (já no banco ou repetidos no próprio arquivo)
      next if existentes.include?(hash_chave)
      existentes.add(hash_chave)

      registros << {
        hash_chave: hash_chave,
        nu_documento: nu_documento,
        doc_cedente: doc_cedente,
        nome_fundo: row['NOME_FUNDO'].to_s.strip,
        doc_fundo: row['DOC_FUNDO'].to_s.strip,
        data_aquisicao: parse_data_br(row['DATA_AQUISICAO']),
        dados_originais: row.to_h,
        created_at: agora,
        updated_at: agora
      }
      contador += 1

      if registros.size >= BATCH_SIZE
        Estoque.insert_all(registros)
        puts "Inseridos #{contador} registros..."
        registros.clear
      end
    end

    Estoque.insert_all(registros) if registros.any?

    puts "Importação concluída: #{contador} novos registros. Total no banco: #{Estoque.count}"
  end
end
