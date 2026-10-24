require 'digest'

module Antecipe
  class CsvProcessor
    class << self
      def gerar_hash_chave(nu_documento, doc_cedente)
        chave = "#{nu_documento.to_s.strip}|#{doc_cedente.to_s.strip}"
        Digest::SHA256.hexdigest(chave)
      end

      def gerar_hash_lote(conteudo)
        Digest::SHA256.hexdigest(conteudo.to_s)
      end
    end
  end
end
