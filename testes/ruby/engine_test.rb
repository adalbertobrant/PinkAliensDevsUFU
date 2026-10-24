# Teste do motor de regras via extensão C++.
# Valida as regras de negócio contra o gabarito (resultado_esperado_100k.json).
#
# As 4 regras estruturais (TIPO_RECEBIVEL, PRAZO_MAXIMO, VALOR_MINIMO,
# CONCENTRACAO_MAXIMA_SACADO) devem ter 100% de acerto.
# SITUACAO_CADASTRAL_SACADO segue o cnpj_situacao_mock.csv (fonte de verdade),
# que difere do dataset usado no gabarito — divergência esperada.

require 'json'
require 'digest'

ROOT = File.expand_path('../../', __dir__)
$LOAD_PATH.unshift File.join(ROOT, 'backend', 'lib')

require 'antecipe_core'

# 1. Processa o estoque como lote de entrada
csv = File.read(File.join(ROOT, 'arquivos', 'estoque_antecipe.csv'))
t0 = Time.now
resultado = Antecipe::Motor.processar(csv)
t1 = Time.now

# 2. Carrega o gabarito
esperado = JSON.parse(File.read(File.join(ROOT, 'arquivos', 'resultado_esperado_100k.json')))
exp_por_linha = esperado.to_h { |r| [r['linha'], r] }

# 3. Compara regra por regra
REGRAS = %w[TIPO_RECEBIVEL PRAZO_MAXIMO VALOR_MINIMO CONCENTRACAO_MAXIMA_SACADO]
erros = Hash.new(0)
erros_status = 0

resultado['notas'].each_with_index do |nota, i|
  linha = i + 2 # cabeçalho ocupa a linha 1
  e = exp_por_linha[linha]
  next unless e
  e_bp = e['barrado_por'] || []
  m_bp = nota['motivos'] || []
  REGRAS.each do |regra|
    erros[regra] += 1 if e_bp.include?(regra) != m_bp.include?(regra)
  end
  e_status = e['status'] == 'APROVADO'
  m_status = nota['aprovada']
  erros_status += 1 if e_status != m_status
end

puts "Tempo de processamento: #{(t1 - t0).round(3)}s para #{resultado['notas'].size} notas"
puts "Resumo: aprovadas=#{resultado['resumo']['aprovadas']} recusadas=#{resultado['resumo']['recusadas']}"
puts "Divergência total de status: #{erros_status}"
REGRAS.each { |r| puts "  #{r}: #{erros[r]} divergências" }

# 4. Verifica performance (< 1 minuto = requisito do edital)
if (t1 - t0) < 60
  puts "PERFORMANCE OK (< 60s)"
else
  puts "PERFORMANCE FALHOU (> 60s)"
end

# 5. Verifica regras estruturais (deve ser zero)
estruturais_ok = REGRAS.all? { |r| erros[r].zero? }
puts estruturais_ok ? "REGRAS ESTRUTURAIS: 100% OK" : "REGRAS ESTRUTURAIS: FALHOU"
