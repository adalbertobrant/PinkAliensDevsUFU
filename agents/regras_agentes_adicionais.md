# Regras Adicionais do Antecipe FIDC

Este documento complementa `regras_agentes.md` com as regras presentes em `validadores_antecipe.json` que ainda não estavam especificadas nele.

## Fundo

- **Fundo:** ANTECIPE FIDC
- **CNPJ:** 92.234.400/0001-80

## Validadores adicionais

### CNPJ_SACADO_VALIDO

- **Status:** Ativo
- **Parâmetros:** Nenhum
- **Regra:** O CNPJ do sacado deve ser válido.
- **Resultado em caso de falha:** A nota deve ser recusada.

### SITUACAO_CADASTRAL_SACADO

- **Status:** Ativo
- **Parâmetros:**
  - `situacoes_aceitas`: `["ATIVA"]`
- **Regra:** A situação cadastral do sacado deve ser exatamente `ATIVA`.
- **Resultado em caso de falha:** A nota deve ser recusada.

### TIPO_RECEBIVEL

- **Status:** Ativo
- **Parâmetros:**
  - `tipos_aceitos`: `["Duplicata", "Duplicata de Serviço"]`
- **Regra:** O campo `TIPO_RECEBIVEL` deve conter apenas `Duplicata` ou `Duplicata de Serviço`.
- **Resultado em caso de falha:** A nota deve ser recusada.

### NAO_VENCIDA

- **Status:** Ativo
- **Parâmetros:** Nenhum
- **Regra:** A data de vencimento do recebível deve ser posterior à data base de processamento (`22/10/2026`).
- **Resultado em caso de falha:** A nota deve ser recusada.

### PRAZO_MINIMO

- **Status:** Inativo
- **Parâmetros:**
  - `prazo_minimo_dias`: `30`
- **Regra:** Quando ativado, o prazo entre a data base e o vencimento deve ser maior ou igual a 30 dias.
- **Comportamento:** Esta regra deve ser ignorada enquanto `ativo` for `false`.

### CONCENTRACAO_MAXIMA_CEDENTE

- **Status:** Inativo
- **Parâmetros:**
  - `percentual_maximo`: `8.0`
- **Regra:** Quando ativado, a concentração por cedente não pode ultrapassar 8% da carteira ou do lote avaliado, conforme a definição de base de cálculo adotada pelo sistema.
- **Comportamento:** Esta regra deve ser ignorada enquanto `ativo` for `false`.

## Ajustes em regras existentes

### CONCENTRACAO_MAXIMA_SACADO

- **Status:** Ativo
- **Parâmetros:**
  - `percentual_maximo`: `10.0`
  - `agrupamento`: `RAIZ_CNPJ`
- **Regra:** A concentração do sacado deve ser calculada pela raiz do CNPJ, não pelo CNPJ completo.
- **Limite:** O volume total por raiz de CNPJ não pode exceder 10%.

### SITUACAO_CADASTRAL

- A regra existente deve considerar o validador `SITUACAO_CADASTRAL_SACADO` do JSON.
- A única situação cadastral aceita para o sacado é `ATIVA`.

## Precificação

- **Método:** Desconto simples
- **Taxa mensal:** 2%
- **Base de dias:** 30 dias

### Fórmula

\[
ValorLiquido = ValorNominal \times \left(1 - \frac{TaxaMensal}{100} \times \frac{PrazoDias}{BaseDias}\right)
\]

Onde:

- `ValorNominal` é o valor de face da nota.
- `TaxaMensal` é 2%.
- `PrazoDias` é o número de dias entre a data base e a data de vencimento.
- `BaseDias` é 30.

### Exemplo

Para uma nota de R$ 1.000,00 com vencimento em 30 dias:

\[
ValorLiquido = 1000 \times \left(1 - \frac{2}{100} \times \frac{30}{30}\right) = 980
\]

O valor líquido é R$ 980,00.

## Regra geral de execução

- O motor de regras deve ler os códigos, o status `ativo` e os `parametros` diretamente de `validadores_antecipe.json`.
- Nenhum limite, tipo aceito, situação cadastral, percentual ou taxa pode estar fixado no código-fonte.
- Regras com `ativo: false` devem ser ignoradas na avaliação.
- Uma nota só é aprovada se atender a todos os validadores ativos.
