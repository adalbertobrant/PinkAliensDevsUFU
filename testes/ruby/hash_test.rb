require 'test/unit'
require_relative '../../backend/lib/antecipe/csv_processor'

class HashTest < Test::Unit::TestCase
  def test_gerar_hash_chave
    hash = Antecipe::CsvProcessor.gerar_hash_chave('NF-1001', '23.456.789/0001-01')
    assert_not_nil hash
    assert_equal 64, hash.length # SHA256
  end

  def test_hash_consistente
    hash1 = Antecipe::CsvProcessor.gerar_hash_chave('NF-1001', '23.456.789/0001-01')
    hash2 = Antecipe::CsvProcessor.gerar_hash_chave('NF-1001', '23.456.789/0001-01')
    assert_equal hash1, hash2
  end
end
