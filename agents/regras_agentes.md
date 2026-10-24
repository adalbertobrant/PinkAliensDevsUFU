# regras do hacktoon
{
"evento": "Hackathon Antecipe",
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
"requisitos_tecnicos_edital": {
"escalabilidade_e_performance": {
"volumetria_alvo": "Processamento em lote de 100.000 a 500.000 linhas de recebíveis",
"requisito": "Concluir todas as etapas de processamento com alta velocidade e resiliência"
},
"arquitetura_e_design_de_codigo": {
"filosofia_unix": "Segregação estrita de tarefas (Single Responsibility / modularidade) e código limpo",
"motor_regras_desacoplado": "Regras lidas dinamicamente do JSON sem valores hardcoded, permitindo alterações em runtime sem necessidade de redeploy"
},
"observabilidade_e_seguranca": {
"logs_estruturados": true,
"mascaramento_privacidade": "Ausência estrita de dados sensíveis ou registros do CSV nos logs da aplicação",
"gestao_credenciais": "Ausência total de chaves, segredos ou variáveis de ambiente confidenciais no código-fonte"
},
"explicabilidade_e_ux": {
"clareza_recusas": "Explicações amigáveis e inequívocas para cada nota recusada, orientadas ao entendimento do cedente"
},
"rastreabilidade_prompts_ia": {
"requisito": "Registro cronológico dos prompts executados pelo agente/desenvolvedor e mapeamento da ação tomada com cada saída produzida"
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
"itens_obrigatorios": [
{
"item": 1,
"titulo": "Repositório",
"descricao": "Repositório com o código com a resolução do exercício proposto."
},
{
"item": 2,
"titulo": "README",
"descricao": "Passo a passo para rodar a aplicação do zero: dependências, comandos e variáveis de ambiente. O projeto cuja aplicação não puder ser executada seguindo as instruções será desclassificado."
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
"Suporte a processamento de 100k a 500k linhas com performance",
"Logs estruturados sem conter dados do CSV e sem segredos/tokens expostos"
]
},
{
"item": 4,
"titulo": "Relatório curto",
"descricao": "O que o time construiu, as tecnologias usadas, as principais decisões e o que ficou de fora (pode estar no README)."
},
{
"item": 5,
"titulo": "Histórico de Prompts de IA",
"descricao": "Arquivo com todos os prompts utilizados durante o desenvolvimento, em ordem cronológica, acompanhados da descrição do que foi feito com cada resposta."
}
]
},
"anexos_mencionados": [
"estoque_antecipe_100k.zip",
"validadores_antecipe.json",
"resultado_esperado_100k.json"
]
}

