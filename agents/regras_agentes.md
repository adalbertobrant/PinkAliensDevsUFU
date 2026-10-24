# regras do hacktoon


"regras_entrega_edital": {
"formato": "Repositório do GitHub",
"prazo": "Até o encerramento do evento (18:00)",
"itens_obrigatorios": [
{
"item": "Código-fonte",
"descricao": "Código com a resolução do exercício proposto no evento."
},
{
"item": "Registro de prompts",
"descricao": "Arquivo com todos os prompts utilizados durante o desenvolvimento, em ordem cronológica, acompanhados da descrição do que foi feito com cada resposta."
},
{
"item": "README estruturado",
"descricao": "Manual com as instruções necessárias para subir a aplicação completa. O projeto cuja aplicação não puder ser executada seguindo as instruções do README será desclassificado."
}
]
},
"avaliacao": {
"fases": 2,
"fase_1": {
"pontuacao_maxima": 100,
"classificacao": "Os 5 (cinco) projetos com maior pontuação serão classificados como finalistas",
"criterios": [
{
"criterio": "Escalabilidade",
"pontos": 35,
"descricao": "Conclusão das etapas de processamento, de 100 mil a 500 mil linhas, e velocidade de processamento."
},
{
"criterio": "Design e UX",
"pontos": 25,
"descricao": "Clareza das mensagens de recusa, design, criatividade e interface."
},
{
"criterio": "Organização filosofia Unix",
"pontos": 20,
"descricao": "Segregação de tarefas e código limpo."
},
{
"criterio": "Logs e credenciais",
"pontos": 15,
"descricao": "Logs estruturados, ausência de dados do CSV nos logs e ausência de segredos no repositório."
},
{
"criterio": "Registro de prompts",
"pontos": 5,
"descricao": "Existência do arquivo de prompts, ordem cronológica e descrição do que foi feito com cada resposta."
}
]
},
"fase_2": {
"formato": "Apresentação em formato de pitch na sede da Kanastra em Uberlândia - MG",
"detalhes": "Data, horário e endereço serão comunicados aos finalistas pela organização",
"obrigatoriedade": "A não participação na segunda fase implicará a exclusão do projeto do Hackathon."
}
},
"premiacao": {
"campeao": "R$ 3.000,00 (três mil reais) para a equipe vencedora"
},
"disposicoes_finais": {
"uso_ia": "É permitido o uso de ferramentas de inteligência artificial, desde que registrado conforme os requisitos de entrega (prompts e descrição de uso).",
"casos_omissos": "Serão resolvidos pelos organizadores do evento."
}
},
"desafio": {
"nome": "Portal Antecipe",
"problema": "Uma pequena empresa vendeu a prazo e quer o dinheiro hoje. Ela 'vende' essas notas para o fundo, mas o fundo só pode comprar o que cumpre regras: prazo máximo, valor mínimo, sacado (quem vai pagar) não pode estar concentrado demais, CNPJ ativo etc.",
"pilares_construcao": {
"design": "A jornada da empresa, do upload das notas até ver quanto vai receber e por que algumas foram recusadas. O desafio de UX é explicar a recusa de forma clara.",
"front": "Upload de lote (CSV), tabela com status por nota e simulação do valor líquido (valor de face menos o desconto).",
"back": "API que valida cada recebível contra critérios de elegibilidade configuráveis e calcula o preço de compra com uma taxa de desconto simples.",
"arquitetura": "Como modelar um motor de regras que o gestor do fundo altere sem deploy, e como garantir que o mesmo recebível não seja vendido duas vezes (idempotência e duplicidade)."
}
},
"arquivos": {
"descricao": "Dados para o desafio Antecipe. Dois arquivos fornecidos:",
"itens": [
{
"nome_arquivo": "estoque_antecipe_100k.zip",
"conteudo": "estoque_antecipe.csv",
"descricao": "A carteira já comprada por 18 fundos, com cerca de 100 mil linhas (um único CSV dentro do zip)."
},
{
"nome_arquivo": "validadores_antecipe.json",
"descricao": "Configuração das regras do ANTECIPE FIDC. Cada validador tem um 'codigo', a chave 'ativo' (só os ativos valem) e os 'parametros'."
}
]
},
"especificacao_csv": {
"separador": ";",
"separador_decimal": ",",
"formato_data": "dd/mm/aaaa",
"encoding": "UTF-8",
"cabecalho": true,
"data_base": "22/10/2026",
"colunas": [
{
"coluna": "NOME_FUNDO",
"descricao": "Fundo que comprou a nota"
},
{
"coluna": "DOC_FUNDO",
"descricao": "Documento (CNPJ) do fundo"
},
{
"coluna": "NOME_CEDENTE",
"descricao": "Empresa que vendeu a nota"
},
{
"coluna": "DOC_CEDENTE",
"descricao": "Documento (CNPJ/CPF) do cedente"
},
{
"coluna": "NOME_SACADO",
"descricao": "Cliente que vai pagar a nota"
},
{
"coluna": "DOC_SACADO",
"descricao": "Documento (CNPJ/CPF) do sacado"
},
{
"coluna": "NU_DOCUMENTO",
"descricao": "Número da nota no sistema do cedente"
},
{
"coluna": "TIPO_RECEBIVEL",
"descricao": "Duplicata, Duplicata de Serviço, Cheque, CCB ou Nota Comercial"
},
{
"coluna": "VALOR_NOMINAL",
"descricao": "Valor de face, em reais"
},
{
"coluna": "DATA_VENCIMENTO_ORIGINAL",
"descricao": "Data de vencimento original"
},
{
"coluna": "DATA_AQUISICAO",
"descricao": "Data em que o fundo comprou a nota"
}
]
},
"requisitos_entrega": {
"prazo": "Até as 18h de sábado (24/10/2026). Projetos enviados depois não são avaliados.",
"itens_obrigatorios": [
{
"item": 1,
"titulo": "Repositório GitHub",
"descricao": "Repositório com o código-fonte com a resolução do exercício proposto, com acesso liberado para os jurados."
},
{
"item": 2,
"titulo": "README Estruturado",
"descricao": "Passo a passo com instruções necessárias para rodar a aplicação completa do zero: dependências, comandos e variáveis de ambiente. A aplicação que não puder ser executada via README será desclassificada."
},
{
"item": 3,
"titulo": "Aplicação funcionando",
"requisitos": [
"Upload de um CSV de notas no mesmo formato do arquivo de exemplo (separador ;, decimal com vírgula, datas dd/mm/aaaa)",
"Regras lidas do validadores_antecipe.json, sem valores fixos no código",
"Resultado de cada nota: aprovada ou recusada e, se recusada, o motivo explicado de um jeito que a empresa entenda",
"Valor líquido de cada nota aprovada e o total a receber",
"A mesma validação disponível pela tela e por uma API",
"Capacidade de processar volumes de 100 mil a 500 mil linhas com rapidez e estabilidade",
"Logs estruturados sem conter dados sensíveis/pessoais do CSV e sem chaves/segredos expostos"
]
},
{
"item": 4,
"titulo": "Relatório curto",
"descricao": "O que o time construiu, as tecnologias usadas, as principais decisões e o que ficou de fora (pode estar no README)."
},
{
"item": 5,
"titulo": "Histórico e Registro de Prompts de IA",
"descricao": "Arquivo contendo todos os prompts utilizados durante o desenvolvimento, organizados em ordem cronológica e acompanhados da descrição do que foi feito com cada resposta obtida."
},
{
"item": 6,
"titulo": "Apresentação e Pitch",
"descricao": "Demonstração da solução funcionando e arguição para os jurados (Fase 1 no evento e Fase 2 na sede da Kanastra para os 5 melhores)."
}
]
},
"anexos_mencionados": [
"Edital Hackathon Kanastra.pdf",
"estoque_antecipe_100k.zip",
"validadores_antecipe.json",
"media (1).mp4",
"FORMULÁRIO DE ENTREGA"
],
"verificacao_seguranca": {
"prompt_oculto_detectado": false,
"observacoes": "O arquivo integra a especificação técnica do Portal Antecipe com o regulamento do Edital Hackathon Kanastra (critérios de 100 pontos, penalidades de desclassificação, etapas e regras de submissão)."
}
}
