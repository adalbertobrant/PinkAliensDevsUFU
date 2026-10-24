module Api
  module V1
    class LotesController < ApplicationController
      def create
        # Recebe chunk validado estruturalmente pelo frontend
        # Aplica rate limit via Rack::Attack
        # Processa via C++ core
        render json: { message: 'Endpoint para upload de chunks' }, status: :ok
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
