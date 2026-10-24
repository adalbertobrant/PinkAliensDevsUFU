require 'csv'
require 'digest'

namespace :antecipe do
  desc 'Importa estoque historico do estoque_antecipe.csv'
  task import_estoque: :environment do
    arquivo = Rails.root.join('..', 'arquivos', 'estoque_antecipe.csv')
    puts "Importando de #{arquivo}"
    
    count = 0
    CSV.foreach(arquivo, col_sep: ';', headers: true, encoding: 'UTF-8') do |row|
      nu_documento = row['NU_DOCUMENTO'].to_s.strip
      doc_cedente = row['DOC_CEDENTE'].to_s.strip
      
      chave = "#{nu_documento}|#{doc_cedente}"
      hash_chave = Digest::SHA256.hexdigest(chave)
      
      Estoque.find_or_create_by!(hash_chave: hash_chave) do |e|
        e.nu_documento = nu_documento
        e.doc_cedente = doc_cedente
        e.nome_fundo = row['NOME_FUNDO']
        e.doc_fundo = row['DOC_FUNDO']
        e.data_aquisicao = row['DATA_AQUISICAO']
        e.dados_originais = row.to_h
      end
      count += 1
      puts "Processados #{count}..." if count % 10000 == 0
    end
    
    puts "Importados #{count} registros"
  end
end
