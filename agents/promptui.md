Atue como um Designer de Produto Sênior e Engenheiro Front-end especializado em UX para fintechs.
Crie uma interface funcional, responsiva e interativa para o portal “Antecipe”, uma plataforma de antecipação de recebíveis FIDC da Kanastra.
A interface deve representar uma experiência real de produção. Não inclua abas de teste, seletor de cenários, botões para simular sucesso, timeout ou erro de rede, nem qualquer controle identificado como ambiente de testes.
A jornada deve acontecer de forma contínua na mesma aplicação:
Orientação para preparação do arquivo.
2. Upload do lote.
3. Processamento.
4. Resultado financeiro consolidado.
5. Diagnóstico das inconsistências.
6. Consulta paginada das notas.
7. Correção ou exportação das recusadas.
8. Confirmação da antecipação.
IDENTIDADE VISUAL KANASTRA
Aplique a linguagem visual oficial da Kanastra:
Verde profundo: #193C32.
Verde institucional: #14735A.
Verde de destaque: #2DAA82.
Fundo neutro: #F3F2F3.
Cards em branco.
Bordas sutis em #E2E8F0.
Vermelho refinado para recusas e erros.
Âmbar para alertas e pendências.
Cinza neutro para estados inativos.
Sombras discretas.
Use a hierarquia tipográfica:
Vinila Extended Light para títulos principais.
Inter Display Medium para subtítulos, indicadores e valores financeiros.
Inter Regular para textos, formulários e tabelas.
Numerais tabulares para valores, notas, CNPJs, contagens, dias e métricas de tempo.
Use cards com cantos suavemente arredondados, botões compactos, ícones lineares e alta densidade de informação sem poluição visual.




ETAPA 1 — ONBOARDING
No início da página, apresente três cards didáticos:
Prepare seu lote
“Envie seu arquivo CSV com separador ponto e vírgula (;), datas em dd/mm/aaaa e valores com vírgula.”
2. Análise Instantânea
“Nosso motor valida prazos, concentração de crédito, duplicidades e a situação cadastral do CNPJ de cada sacado.”
3. Liquidez ou Correção
“Receba o valor líquido das notas aprovadas e corrija pendências diretamente na plataforma.”
Os cards devem usar ícones lineares na cor verde institucional e superfícies minimalistas.




ETAPA 2 — UPLOAD
Crie uma área de drag and drop para arquivos CSV.
Permita:
Arrastar e soltar o arquivo.
Selecionar manualmente.
Visualizar nome e tamanho.
Remover ou substituir o arquivo.
Iniciar o processamento por meio do botão “Processar Lote”.
Aceite apenas arquivos CSV e apresente orientação clara em caso de formato incompatível.






ETAPA 3 — PROCESSAMENTO
Após o envio, exiba:
Barra de progresso esmeralda.
Percentual processado.
Etapa atual.
Tempo decorrido.
Previsão restante.
Botão “Cancelar Envio”.
Etapas:
Lendo arquivo.
Validando integridade e duplicidades.
Consultando estoque.
Verificando situação cadastral dos CNPJs.
Finalizando cálculos.
A interface deve prever estados reais de:
Processamento concluído.
Timeout.
Interrupção da conexão.
Cancelamento.
Retomada do processamento.
Em caso de falha, informe que as notas já aprovadas foram preservadas.
Não exiba botões de simulação desses estados. Eles devem aparecer somente quando ocorrerem no fluxo real.






ETAPA 4 — HERO FINANCEIRO
Após o processamento, substitua o foco do upload pelo resultado consolidado.
Crie um card em verde profundo contendo:
Total de títulos submetidos.
Quantidade aprovada para cessão.
Quantidade recusada.
Total bruto aprovado.
Desconto total.
Total líquido a receber.
Destaque o total líquido com tipografia ampla e numerais tabulares.
Inclua o CTA principal:
“Confirmar Antecipação do Lote Aprovado”.
A confirmação deve considerar somente os títulos aprovados.




ETAPA 5 — DIAGNÓSTICO AGRUPADO
Quando houver recusas, apresente um painel orientado a exceções.
Não obrigue o usuário a procurar problemas em milhares de linhas.
Agrupe as inconsistências por categoria, como:
Prazo acima do limite.
Situação cadastral do CNPJ.
Valor abaixo do mínimo.
Concentração do sacado.
Título já negociado.
Duplicidade.
Formato inválido.
Data inválida.
Campo obrigatório ausente.
Cada card deve mostrar:
Nome da categoria.
Quantidade de ocorrências.
Resumo da regra.
Botão “Filtrar na Tabela”.
Botão “Baixar CSV deste Grupo”.
Inclua uma ação geral:
“Baixar CSV com Todas as Notas Recusadas”.
FLUXO HÍBRIDO DE CORREÇÃO
Adote duas estratégias:
Poucos erros:
Permitir correção diretamente na tabela.
Revalidar imediatamente.
Atualizar os totais financeiros.
Muitos erros:
Recomendar o download do CSV de recusadas.
Permitir correção externa em lote.
Permitir reenvio somente das linhas corrigidas.
Preservar todas as notas anteriormente aprovadas.
ETAPA 6 — TABELA SERVER-SIDE
A tabela deve ser preparada para lotes de 100 mil a 500 mil registros.
Não renderize o lote inteiro no navegador.
Renderize somente os registros da página atual.
Apresente as colunas:
NOTA.
SACADO.
CNPJ.
VENCIMENTO.
VALOR.
STATUS DA NOTA.
AÇÕES.
Adicione filtros:
Todas.
Aprovadas.
Recusadas.
Cada filtro deve mostrar sua quantidade total.
Adicione paginação:
10 registros por página.
20 registros por página.
50 registros por página.
100 registros por página.
Botão “Anterior”.
Página atual e total de páginas.
Botão “Próxima”.
Apresente uma indicação discreta de que apenas a página atual está carregada.
Ao trocar de página, carregue somente os dados necessários para aquela página.
TABELA E DENSIDADE
Use:
Cabeçalho em cinza suave.
Rótulos em caixa alta discreta.
Linhas compactas.
Bordas horizontais sutis.
Estados de hover discretos.
Valores monetários alinhados à direita.
Vencimentos alinhados à direita.
Numerais tabulares.
Rolagem horizontal em telas pequenas.
CNPJ
Exiba o CNPJ formatado:
00.000.000/0000-00
Abaixo do número, mostre uma situação cadastral:
Ativo.
Inapto.
Suspenso.
Inativo.
Inválido.
Cores:
Ativo: verde.
Inapto: vermelho.
Suspenso: âmbar.
Inativo: cinza.
Inválido: vermelho.
Uma situação diferente de “Ativo” deve poder gerar recusa, conforme as regras do fundo.
EDIÇÃO INLINE
Para notas recusadas que possam ser corrigidas, exiba o botão:
“Editar e Corrigir”.
A edição deve acontecer na própria tabela.
Permita alterar:
Sacado.
CNPJ.
Data de vencimento.
Valor nominal.
Inclua:
Botão “Cancelar”.
Botão “Revalidar Nota”.
Ao revalidar:
Verifique campos obrigatórios.
Valide o formato da data.
Valide o valor.
Valide os dígitos verificadores do CNPJ.
Atualize a situação cadastral.
Altere o status para “Aprovada” quando a nota se tornar elegível.
Marque a nota como corrigida.
Atualize os contadores.
Atualize o total aprovado.
Atualize o desconto.
Atualize o total líquido a receber.
Remova a nota das exportações de recusadas.
Não permita edição em títulos que não possam ser corrigidos pelo usuário, como títulos definitivamente já negociados, salvo quando houver uma regra específica permitindo nova validação.










BANNER CONTEXTUAL
Ao selecionar uma nota recusada, exiba abaixo da tabela um banner com:
Número da nota.
Valor ou dado encontrado.
Regra esperada.
Motivo da recusa.
Orientação para correção, quando possível.
Exemplos:
“NF 0157 · Prazo acima do limite: vence em 90 dias; o limite configurado é 60.”
“NF 0288 · Situação Cadastral Irregular: o CNPJ 23.456.789/0001-12 encontra-se ‘Inapto’ na Receita Federal; o fundo exige situação ‘Ativo’.”
“NF 0304 · CNPJ Inválido: o documento informado possui erro de dígito verificador.”
SIMULAÇÃO INDIVIDUAL
Ao selecionar uma nota aprovada, exiba uma barra financeira inferior com:
Número da nota.
Valor de face.
Desconto aplicado.
Valor líquido.
Total consolidado do lote.
Exemplo:
“Simulação · NF 0142 → R$ 9.800,00”
EXPORTAÇÕES
Disponibilize:
Baixar CSV corrigido completo.
Baixar todas as notas recusadas.
Baixar recusadas por grupo.
Enviar apenas notas corrigidas.
Os arquivos devem usar:
UTF-8.
Separador ponto e vírgula.
Datas em dd/mm/aaaa.
Decimais com vírgula.
CNPJ formatado.
Linha de origem do CSV.
Status da nota.
Motivo da recusa.
ERROS ESTRUTURAIS
Se o arquivo inteiro for inválido, não mostre a tabela.
Exiba um card de erro com:
Título objetivo.
Explicação do problema.
Exemplo do formato correto.
Botão “Tentar novo upload”.
Trate problemas como:
Separador incorreto.
Padrão numérico inválido.
Data inválida.
Cabeçalho incompleto.
Colunas obrigatórias ausentes.
Codificação diferente de UTF-8.