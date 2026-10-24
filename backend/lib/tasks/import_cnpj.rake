require 'csv'
require 'digest'
require 'set'

namespace :antecipe do
  desc 'Importa situacao cadastral do cnpj_situacao_mock.csv (inserção em lote)'
  task import_cnpj_situacao: :environment do
    arquivo = Rails.root.join('..', 'arquivos', 'cnpj_situacao_mock.csv')
    puts "Importando de #{arquivo}"

    existentes = Set.new(SituacaoCadastral.pluck(:cnpj_hash))
    puts "Registros já existentes: #{existentes.size}"

    agora = Time.current
    registros = []
    contador = 0

    CSV.foreach(arquivo, col_sep: ';', headers: true, encoding: 'UTF-8') do |row|
      doc = row['DOC'].to_s.strip
      situacao = row['SITUACAO_CADASTRAL'].to_s.strip.upcase
      cnpj_normalizado = doc.gsub(/[^0-9]/, '')
      cnpj_hash = Digest::SHA256.hexdigest(cnpj_normalizado)

      next if existentes.include?(cnpj_hash)
      existentes.add(cnpj_hash)

      registros << {
        cnpj_hash: cnpj_hash,
        cnpj_normalizado: cnpj_normalizado,
        situacao: situacao,
        dados_originais: { doc_original: doc, situacao: situacao },
        created_at: agora,
        updated_at: agora
      }
      contador += 1
    end

    SituacaoCadastral.insert_all(registros) if registros.any?

    puts "Importação concluída: #{contador} novos registros. Total no banco: #{SituacaoCadastral.count}"
  end
end
