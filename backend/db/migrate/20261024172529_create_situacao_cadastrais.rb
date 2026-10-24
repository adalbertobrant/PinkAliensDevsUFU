class CreateSituacaoCadastrais < ActiveRecord::Migration[8.0]
  def change
    create_table :situacao_cadastrais, id: :uuid do |t|
      t.string :cnpj_hash, null: false
      t.string :cnpj_normalizado, null: false
      t.string :situacao, null: false
      t.jsonb :dados_originais, default: {}
      t.timestamps
    end
    add_index :situacao_cadastrais, :cnpj_hash, unique: true
    add_index :situacao_cadastrais, :situacao
  end
end
