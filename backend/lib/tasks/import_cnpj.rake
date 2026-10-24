require 'csv'
require 'digest'

namespace :antecipe do
  desc 'Importa situacao cadastral do cnpj_situacao_mock.csv'
  task import_cnpj_situacao: :environment do
    arquivo = Rails.root.join('..', 'arquivos', 'cnpj_situacao_mock.csv')
    puts "Importando de #{arquivo}"
    
    count = 0
    CSV.foreach(arquivo, col_sep: ';', headers: true, encoding: 'UTF-8') do |row|
      doc = row['DOC'].to_s.strip
      situacao = row['SITUACAO_CADASTRAL'].to_s.strip.upcase
      
      # Normalizar CNPJ (remover pontuação)
      cnpj_normalizado = doc.gsub(/[^0-9]/, '')
      cnpj_hash = Digest::SHA256.hexdigest(cnpj_normalizado)
      
      SituacaoCadastral.find_or_create_by!(cnpj_hash: cnpj_hash) do |s|
        s.cnpj_normalizado = cnpj_normalizado
        s.situacao = situacao
        s.dados_originais = { doc_original: doc, situacao: situacao }
      end
      count += 1
    end
    
    puts "Importados #{count} registros"
  end
end
