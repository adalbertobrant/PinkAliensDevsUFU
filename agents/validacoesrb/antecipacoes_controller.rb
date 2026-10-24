# app/controllers/api/v1/antecipacoes_controller.rb
module Api
  module V1
    class AntecipacoesController < ApplicationController
      # POST /api/v1/antecipacoes/validar
      def validar
        # Chama seu serviço de processamento em streaming/lote
        resultado = ProcessadorLoteService.new(params[:file] || params[:csv_content]).executar

        if resultado.erro_estrutural?
          render json: {
            sucesso: false,
            erro: FeedbackCatalog.build(resultado.codigo_erro, resultado.detalhes_erro)
          }, status: :unprocessable_entity
        else
          render json: {
            sucesso: true,
            aviso_idempotencia: resultado.idempotente? ? FeedbackCatalog.build(:LOTE_JA_PROCESSADO_IDEMPOTENCIA) : nil,
            resumo: {
              total_notas: resultado.total_notas,
              total_aprovadas: resultado.total_aprovadas,
              total_recusadas: resultado.total_recusadas,
              valor_bruto_aprovado: resultado.valor_bruto_aprovado,
              desconto_total: resultado.desconto_total,
              total_a_receber: resultado.total_liquido # Valor consolidado
            },
            notas: resultado.notas.map do |nota|
              {
                nu_documento: nota.nu_documento,
                sacado: nota.nome_sacado,
                dias_vencimento: nota.dias_ate_vencimento, # ex: 30, 90, 45
                valor_nominal: nota.valor_nominal,
                status: nota.aprovada? ? 'Aprovada' : 'Recusada',
                valor_liquido: nota.valor_liquido, # Calculado com a taxa de desconto
                feedback: FeedbackCatalog.build(nota.codigo_feedback, nota.parametros_feedback)
              }
            end
          }, status: :ok
        end
      end
    end
  end
end