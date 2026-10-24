class Estoque < ApplicationRecord
  validates :hash_chave, presence: true, uniqueness: true
  validates :nu_documento, presence: true
  validates :doc_cedente, presence: true
end
