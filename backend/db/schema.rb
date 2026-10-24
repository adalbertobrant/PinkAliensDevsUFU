# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.2].define(version: 2026_10_24_172529) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "estoques", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "hash_chave", null: false
    t.string "nu_documento", null: false
    t.string "doc_cedente", null: false
    t.string "nome_fundo"
    t.string "doc_fundo"
    t.date "data_aquisicao"
    t.jsonb "dados_originais", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_chave"], name: "index_estoques_on_hash_chave", unique: true
    t.index ["nu_documento", "doc_cedente"], name: "index_estoques_on_nu_documento_and_doc_cedente"
  end

  create_table "lotes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nome_arquivo", null: false
    t.string "hash_lote", null: false
    t.integer "total_linhas", default: 0
    t.integer "total_aprovadas", default: 0
    t.integer "total_recusadas", default: 0
    t.decimal "valor_total_liquido", precision: 15, scale: 2, default: "0.0"
    t.string "status", default: "processando"
    t.jsonb "metadados", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_lote"], name: "index_lotes_on_hash_lote", unique: true
    t.index ["status"], name: "index_lotes_on_status"
  end

  create_table "recebiveis", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lote_id", null: false
    t.string "hash_chave", null: false
    t.string "nu_documento", null: false
    t.string "doc_cedente", null: false
    t.string "nome_cedente"
    t.string "nome_sacado"
    t.string "doc_sacado"
    t.string "tipo_recebivel"
    t.decimal "valor_nominal", precision: 15, scale: 2
    t.date "data_vencimento_original"
    t.date "data_aquisicao"
    t.integer "prazo_dias"
    t.string "status", null: false
    t.string "motivo_recusa"
    t.decimal "valor_liquido", precision: 15, scale: 2
    t.decimal "taxa_desconto", precision: 5, scale: 4, default: "0.0"
    t.jsonb "validacoes_detalhes", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_chave"], name: "index_recebiveis_on_hash_chave"
    t.index ["lote_id"], name: "index_recebiveis_on_lote_id"
    t.index ["nu_documento", "doc_cedente"], name: "index_recebiveis_on_nu_documento_and_doc_cedente"
    t.index ["status"], name: "index_recebiveis_on_status"
  end

  create_table "situacao_cadastrais", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cnpj_hash", null: false
    t.string "cnpj_normalizado", null: false
    t.string "situacao", null: false
    t.jsonb "dados_originais", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj_hash"], name: "index_situacao_cadastrais_on_cnpj_hash", unique: true
    t.index ["situacao"], name: "index_situacao_cadastrais_on_situacao"
  end

  add_foreign_key "recebiveis", "lotes"
end
