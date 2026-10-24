class CreateLotes < ActiveRecord::Migration[8.0]
  def change
    create_table :lotes, id: :uuid do |t|
      t.string :nome_arquivo, null: false
      t.string :hash_lote, null: false
      t.integer :total_linhas, default: 0
      t.integer :total_aprovadas, default: 0
      t.integer :total_recusadas, default: 0
      t.decimal :valor_total_liquido, precision: 15, scale: 2, default: 0.0
      t.string :status, default: 'processando'
      t.jsonb :metadados, default: {}
      t.timestamps
    end
    add_index :lotes, :hash_lote, unique: true
    add_index :lotes, :status
  end
end
