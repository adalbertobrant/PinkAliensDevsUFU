class CreateRecebiveis < ActiveRecord::Migration[8.0]
  def change
    create_table :recebiveis, id: :uuid do |t|
      t.references :lote, type: :uuid, null: false, foreign_key: true
      t.string :hash_chave, null: false # hash de NU_DOCUMENTO|DOC_CEDENTE
      t.string :nu_documento, null: false
      t.string :doc_cedente, null: false
      t.string :nome_cedente
      t.string :nome_sacado
      t.string :doc_sacado
      t.string :tipo_recebivel
      t.decimal :valor_nominal, precision: 15, scale: 2
      t.date :data_vencimento_original
      t.date :data_aquisicao
      t.integer :prazo_dias
      t.string :status, null: false # 'aprovada' ou 'recusada'
      t.string :motivo_recusa
      t.decimal :valor_liquido, precision: 15, scale: 2
      t.decimal :taxa_desconto, precision: 5, scale: 4, default: 0.0
      t.jsonb :validacoes_detalhes, default: {}
      t.timestamps
    end
    add_index :recebiveis, :hash_chave
    add_index :recebiveis, [:nu_documento, :doc_cedente]
    add_index :recebiveis, :status
    add_index :recebiveis, :lote_id
  end
end
