Atue como um Designer de Produto Sênior e Engenheiro Front-end especializado em UX para fintechs.

Crie um protótipo funcional, responsivo e interativo para o portal “Antecipe”, uma plataforma de antecipação de recebíveis FIDC da Kanastra.

Todo o protótipo deve ser entregue em um único arquivo HTML, utilizando Tailwind CSS via CDN e JavaScript puro. Preserve uma arquitetura de interface preparada para lotes entre 100 mil e 500 mil linhas, sem renderizar o lote inteiro no DOM.

IDENTIDADE VISUAL

Aplique a linguagem visual oficial da Kanastra:

- Verde profundo: #193C32.
- Verde institucional: #14735A.
- Verde de destaque: #2DAA82.
- Fundo neutro: #F3F2F3.
- Cards em branco.
- Bordas sutis em #E2E8F0.
- Vermelho refinado para recusas.
- Âmbar para alertas e timeout.
- Cinza para estados inativos.
- Sombras discretas.

Use a seguinte hierarquia tipográfica:

- Vinila Extended Light para títulos principais.
- Inter Display Medium para subtítulos, cards e valores financeiros.
- Inter Regular para corpo, formulários e tabelas.
- Numerais tabulares para valores, contagens, notas, CNPJs, dias e métricas de tempo.

A interface deve possuir duas abas navegáveis no topo:

1. Upload & Monitoramento.
2. Análise & Edição de Notas.

ABA 1 — UPLOAD & MONITORAMENTO

Adicione três cards de onboarding:

1. Prepare seu lote
“Envie seu arquivo CSV com separador ponto e vírgula (;), datas em dd/mm/aaaa e valores com vírgula.”

2. Análise Instantânea
“Nosso motor valida prazos, concentração de crédito, duplicidades e a situação cadastral do CNPJ de cada sacado.”

3. Liquidez ou Correção
“Receba o valor líquido das notas aprovadas e corrija pendências diretamente na tela.”

Inclua uma área de drag and drop para arquivos CSV com:

- Seleção manual.
- Nome do arquivo.
- Tamanho.
- Remoção do arquivo.
- Botão Processar Lote.

Durante o processamento, exiba:

- Barra de progresso esmeralda.
- Percentual.
- Etapa atual.
- Tempo decorrido.
- Previsão restante.
- Botão Cancelar Envio.

As etapas devem ser:

- Lendo arquivo.
- Validando integridade e duplicidades.
- Consultando estoque.
- Finalizando cálculos.

Inclua estados de:

- Sucesso.
- Timeout.
- Erro de conexão.
- Cancelamento.
- Reconexão.
- Retomada do processamento.

As notas já aprovadas devem permanecer preservadas.

ABA 2 — CENTRAL HÍBRIDA DE ANÁLISE

Mantenha um seletor com 14 cenários agrupados em:

- Sucesso e protótipo-base.
- Estrutura e formatação do CSV.
- Regras de negócio e elegibilidade.
- Integridade, duplicidade e idempotência.

Para erros estruturais do arquivo, substitua a tabela por um card de erro com orientação clara.

HERO FINANCEIRO

Crie um card em verde profundo contendo:

- Total de títulos submetidos.
- Quantidade aprovada para cessão.
- Total líquido a receber.
- Botão “Confirmar Antecipação do Lote Aprovado”.

Utilize como referência:

- 50.000 títulos submetidos.
- 48.200 aprovados.
- 1.800 recusados.
- R$ 4.280.950,00 a receber.

DIAGNÓSTICO AGRUPADO

Exiba cards de inconsistências por categoria:

1. Prazos
“1.200 notas com vencimento acima do limite de 60 dias.”

2. Situação Cadastral
“450 notas com CNPJ irregular.”

3. Valor Mínimo
“150 notas abaixo do piso de R$ 1.000.”

Cada card deve possuir:

- Quantidade de ocorrências.
- Botão “Filtrar na Tabela”.
- Botão “Baixar CSV”.

Inclua a ação:

“Baixar CSV com Todas as Notas Recusadas”.

TABELA SERVER-SIDE

A tabela deve simular paginação server-side e renderizar somente a página atual.

Colunas:

- NOTA.
- SACADO.
- CNPJ.
- VENCIMENTO.
- VALOR.
- STATUS DA NOTA.
- AÇÕES.

Inclua filtros com contadores:

- Todas (50.000).
- Aprovadas (48.200).
- Recusadas (1.800).

Controles:

- 10, 20, 50 ou 100 linhas por página.
- Anterior.
- Página atual de total de páginas.
- Próxima.
- Indicador da quantidade de linhas presentes no DOM.

A tabela deve gerar os registros da página sob demanda, sem criar previamente dezenas de milhares de objetos ou elementos HTML.

CNPJ

Mostre o CNPJ formatado e um badge cadastral:

- Ativo.
- Inapto.
- Suspenso.
- Inativo.
- Inválido.

Use verde para Ativo, vermelho para Inapto e Inválido, âmbar para Suspenso e cinza para Inativo.

QUICK FIX

Para notas recusadas, exiba “Editar e Corrigir”.

A edição inline deve permitir alterar:

- Sacado.
- CNPJ.
- Vencimento.
- Valor nominal.

Inclua o botão “Revalidar Nota”.

Após uma correção válida:

- Alterar o status para Aprovada.
- Atualizar o CNPJ para Ativo.
- Atualizar a quantidade de aprovadas.
- Atualizar o total líquido.
- Remover a nota das exportações de recusadas.
- Marcar visualmente a nota como corrigida.

FLUXO HÍBRIDO

Para até 10 inconsistências, priorize a edição inline.

Para grandes volumes, oriente o usuário a baixar o CSV do grupo ou o CSV completo de recusadas, corrigir externamente e reenviar somente as notas corrigidas.

EXPORTAÇÃO

Inclua:

- Baixar CSV corrigido completo.
- Baixar todas as notas recusadas.
- Baixar recusadas de cada grupo.
- Enviar apenas notas corrigidas.

Os arquivos devem usar:

- UTF-8.
- Separador ponto e vírgula.
- Datas em dd/mm/aaaa.
- Valores decimais com vírgula.
- Linha de origem.
- Motivo da recusa.

FECHAMENTO

Abaixo da tabela, exiba:

- Banner contextual com a justificativa da recusa selecionada.
- Barra financeira fixa com:
  - Simulação da nota em foco.
  - Valor de face.
  - Desconto individual.
  - Total de notas.
  - Quantidade aprovada.
  - Desconto total.
  - Total a receber.

REQUISITOS DE UX

- Priorize o valor aprovado.
- Não bloqueie o lote por causa de duplicidades ou recusas.
- Preserve as notas já aprovadas.
- Mantenha feedback imediato em todas as ações.
- Use foco visível e contraste acessível.
- Garanta navegação por teclado.
- Use transições discretas.
- Evite sombras pesadas.
- Mantenha alta densidade sem poluição visual.
- Não remova nenhuma funcionalidade ao alternar cenários.