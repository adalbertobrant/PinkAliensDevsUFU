class SituacaoCadastral < ApplicationRecord
  self.table_name = 'situacao_cadastrais'
  
  validates :cnpj_hash, presence: true, uniqueness: true
  validates :cnpj_normalizado, presence: true
  validates :situacao, presence: true
end
EOF
