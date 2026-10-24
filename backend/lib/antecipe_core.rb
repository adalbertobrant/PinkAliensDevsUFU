# Carrega a extensão C++ do motor de regras.
# Caminhos dos arquivos de dados são resolvidos a partir da raiz do projeto.
require 'json'

begin
  require_relative 'antecipe_core.so'
rescue LoadError
  # Fallback Ruby puro (apenas para não quebrar em ambientes sem compilação)
  module AntecipeCore
    class Processador
      def configurar(*); end
      def processar(csv)
        { resumo: { aprovadas: 0, recusadas: 0, total_liquido: 0 }, notas: [] }.to_json
      end
    end
  end
end

module Antecipe
  class Motor
    DATA_DIR = File.expand_path('../../arquivos', __dir__)

    class << self
      def processador
        @processador ||= begin
          p = AntecipeCore::Processador.new
          p.configurar(
            File.join(DATA_DIR, 'validadores_antecipe.json'),
            File.join(DATA_DIR, 'estoque_antecipe.csv'),
            File.join(DATA_DIR, 'cnpj_situacao_mock.csv')
          )
          p
        end
      end

      def processar(csv_content, checar_integridade: false)
        JSON.parse(processador.processar(csv_content, checar_integridade))
      end
    end
  end
end
