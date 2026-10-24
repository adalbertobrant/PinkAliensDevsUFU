class Recebivel < ApplicationRecord
  belongs_to :lote
  validates :hash_chave, presence: true
  validates :nu_documento, presence: true
  validates :doc_cedente, presence: true
  validates :status, presence: true, inclusion: { in: ['aprovada', 'recusada'] }
end
