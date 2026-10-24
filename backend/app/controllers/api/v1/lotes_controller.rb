module Api
  module V1
    class LotesController < ApplicationController
      # POST /api/v1/lotes
      # Recebe o conteúdo CSV (já validado estruturalmente no frontend)
      # e retorna o resultado do motor de regras.
      def create
        csv_content = params[:conteudo].presence || params[:csv_content].presence
        nome_arquivo = params[:nome_arquivo].presence || 'lote.csv'

        if csv_content.blank?
          return render json: {
            sucesso: false,
            erro: { codigo: 'ERR_CSV_VAZIO', mensagem: 'Nenhum conteúdo CSV foi enviado.' }
          }, status: :unprocessable_entity
        end

        resultado = ProcessadorLoteService.new(csv_content, nome_arquivo: nome_arquivo).executar

        render json: {
          sucesso: true,
          idempotente: resultado[:idempotente],
          resumo: resultado[:resumo],
          notas: resultado[:notas]
        }, status: :ok
      rescue StandardError => e
        # Log estruturado SEM dados sensíveis do CSV
        Rails.logger.error("Erro ao processar lote: #{e.class} - #{e.message}")
        render json: {
          sucesso: false,
          erro: { codigo: 'ERR_PROCESSAMENTO', mensagem: 'Falha ao processar o lote.' }
        }, status: :unprocessable_entity
      end

      def show
        lote = Lote.find(params[:id])
        render json: lote.as_json(include: :recebiveis)
      end

      def index
        lotes = Lote.order(created_at: :desc).limit(50)
        render json: lotes
      end
    end
  end
end
