class Lote < ApplicationRecord
  has_many :recebiveis, dependent: :destroy
  validates :nome_arquivo, presence: true
  validates :hash_lote, presence: true, uniqueness: true

  def totalizar
    aprovadas = recebiveis.where(status: 'aprovada')
    self.total_aprovadas = aprovadas.count
    self.total_recusadas = recebiveis.where(status: 'recusada').count
    self.total_linhas = recebiveis.count
    self.valor_total_liquido = aprovadas.sum(:valor_liquido) || 0
    self.status = 'concluido'
    save!
  end
end
