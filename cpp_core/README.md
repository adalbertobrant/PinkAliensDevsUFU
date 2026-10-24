# C++ Core - Motor de Regras

Extensão nativa Ruby via FFI/Rice para processamento pesado.

## Responsabilidades
- Processar chunks de CSV já validados estruturalmente
- Ler regras dinâmicas de `arquivos/validadores_antecipe.json` (sem hardcode)
- Verificar contra estoque histórico (`arquivos/estoque_antecipe.csv`)
- Verificar duplicados dentro do lote
- Aplicar validadores: PRAZO_MAXIMO, VALOR_MINIMO, CONCENTRACAO_SACADO, SITUACAO_CADASTRAL
- Calcular desconto simples e valor líquido
- Gerar explicações claras para recusas
- Hash por `NU_DOCUMENTO|DOC_CEDENTE`

## Performance
Otimizado para processar 100k-500k linhas com alta velocidade.

## Build
Compilado como extensão nativa Ruby via Rice.
