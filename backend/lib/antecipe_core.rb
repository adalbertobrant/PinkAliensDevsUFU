begin
  require_relative 'antecipe_core.so'
rescue LoadError
  begin
    require 'antecipe_core'
  rescue LoadError
    module AntecipeCore
      class Processador
        def processar_chunk(chunk_data)
          []
        end
        def calcular_hash_chave(nu_doc, doc_cedente)
          "#{nu_doc}|#{doc_cedente}"
        end
      end
    end
  end
end
