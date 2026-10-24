class CreateEstoques < ActiveRecord::Migration[8.0]
  def change
    create_table :estoques, id: :uuid do |t|
      t.string :hash_chave, null: false # hash de NU_DOCUMENTO|DOC_CEDENTE
      t.string :nu_documento, null: false
      t.string :doc_cedente, null: false
      t.string :nome_fundo
      t.string :doc_fundo
      t.date :data_aquisicao
      t.jsonb :dados_originais, default: {}
      t.timestamps
    end
    add_index :estoques, :hash_chave, unique: true
    add_index :estoques, [:nu_documento, :doc_cedente]
  end
end
