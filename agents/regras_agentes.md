#Regras Hackthon
{
  "evento": "Hackathon Antecipe",
  "desafio": {
    "nome": "Antecipe",
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
  "validacoes_e_excecoes": {
    "excecoes_estruturais_formato_csv": [
      {
        "id": "ERR_CSV_SEPARATOR",
        "cenario": "Separador incorreto (ex.: uso de vírgula em vez de ponto e vírgula)",
        "mensagem_feedback": "Não conseguimos ler o arquivo: o separador de colunas deve ser ponto e vírgula (;).",
        "acao_usuario": "Abrir a planilha/arquivo, salvar ou exportar no formato CSV delimitado por ponto e vírgula (;) e reenviar."
      },
      {
        "id": "ERR_CSV_NUMERIC_FORMAT",
        "cenario": "Padrão numérico inválido (ex.: ponto decimal em VALOR_NOMINAL)",
        "mensagem_feedback": "Erro no formato de valor na linha {linha}: os centavos devem ser separados por vírgula (ex.: 1000,50 e não 1000.50).",
        "acao_usuario": "Ajustar a coluna de valor nominal no arquivo para o padrão com vírgula decimal e reenviar."
      },
      {
        "id": "ERR_CSV_DATE_FORMAT",
        "cenario": "Formato de data inválido (ex.: aaaa-mm-dd ou data corrompida)",
        "mensagem_feedback": "Data inválida na nota {nu_documento}: as datas devem estar no padrão brasileiro dia/mês/ano (dd/mm/aaaa).",
        "acao_usuario": "Corrigir as colunas DATA_VENCIMENTO_ORIGINAL ou DATA_AQUISICAO para dd/mm/aaaa."
      },
      {
        "id": "ERR_CSV_HEADER_MISSING",
        "cenario": "Cabeçalho ausente ou colunas faltantes",
        "mensagem_feedback": "Estrutura incompleta: não encontramos as colunas obrigatórias no cabeçalho do arquivo (ex.: DOC_CEDENTE, NU_DOCUMENTO).",
        "acao_usuario": "Baixar o modelo oficial de cabeçalho, conferir as colunas obrigatórias e submeter novamente."
      },
      {
        "id": "ERR_CSV_ENCODING",
        "cenario": "Codificação incorreta (não UTF-8)",
        "mensagem_feedback": "Erro de codificação de caracteres: salve seu arquivo com a codificação UTF-8 para evitar caracteres ilegíveis.",
        "acao_usuario": "Salvar o arquivo selecionando a opção CSV UTF-8 no editor de planilhas e reenviar."
      }
    ],
    "excecoes_negocio_elegibilidade": [
      {
        "codigo_validador": "PRAZO_MAXIMO",
        "cenario": "Prazo acima do limite máximo",
        "mensagem_feedback": "NF {nu_documento} · Prazo acima do limite: vence em {prazo_dias} dias; o limite configurado pelo fundo é de {limite_dias} dias.",
        "acao_usuario": "Remover a nota deste lote ou negociar prazos menores de vencimento para futuras antecipações."
      },
      {
        "codigo_validador": "VALOR_MINIMO",
        "cenario": "Valor abaixo do mínimo permitido",
        "mensagem_feedback": "NF {nu_documento} · Valor abaixo do mínimo: a nota é de R$ {valor_nominal}, mas o fundo só aceita títulos a partir de R$ {limite_minimo}.",
        "acao_usuario": "Agrupar recebíveis ou selecionar notas de maior valor para submissão."
      },
      {
        "codigo_validador": "CONCENTRACAO_SACADO",
        "cenario": "Concentração excessiva do sacado",
        "mensagem_feedback": "NF {nu_documento} · Concentração de sacado excedida: o cliente {nome_sacado} já atingiu o limite máximo de crédito permitido pelo fundo.",
        "acao_usuario": "Selecionar notas fiscais emitidas para outros clientes/sacados que possuam limite disponível no fundo."
      },
      {
        "codigo_validador": "SITUACAO_CADASTRAL",
        "cenario": "CNPJ ou cadastro inativo",
        "mensagem_feedback": "NF {nu_documento} · Irregularidade cadastral: o documento do sacado ou cedente encontra-se com restrição ou inativo.",
        "acao_usuario": "Verificar a regularidade do CNPJ/CPF junto à Receita Federal ou substituir a nota por outra com cadastro regular."
      }
    ],
    "excecoes_integridade_e_idempotencia": [
      {
        "id": "ERR_STOCK_ALREADY_SOLD",
        "cenario": "Recebível já vendido (Estoque histórico)",
        "chave_verificacao": ["NU_DOCUMENTO", "DOC_CEDENTE"],
        "mensagem_feedback": "NF {nu_documento} · Título já negociado: esta nota já foi adquirida anteriormente por um fundo da carteira em {data_aquisicao}.",
        "acao_usuario": "Remover a nota do lote atual, pois recebíveis já vendidos não podem ser recomprados."
      },
      {
        "id": "ERR_BATCH_DUPLICATE",
        "cenario": "Duplicidade dentro do mesmo lote submetido",
        "chave_verificacao": ["NU_DOCUMENTO", "DOC_CEDENTE"],
        "mensagem_feedback": "NF {nu_documento} · Nota duplicada: este mesmo documento aparece mais de uma vez no arquivo enviado.",
        "acao_usuario": "Manter apenas uma linha do título no arquivo CSV e excluir as duplicatas antes do reenvio."
      },
      {
        "id": "WARN_BATCH_IDEMPOTENT",
        "cenario": "Submissão repetida do mesmo lote (Idempotência)",
        "mensagem_feedback": "Este lote já foi processado anteriormente. Exibindo os resultados da simulação original.",
        "acao_usuario": "Visualizar a simulação já realizada ou enviar um novo arquivo com notas diferentes."
      }
    ]
  },
  "criterios_sucesso_motor_e_api": [
    {
      "categoria": "Upload de Lote",
      "regra": "Estrutura e Codificação do CSV",
      "condicao_sucesso": "Arquivo com separador ';', codificação UTF-8 e cabeçalho oficial na primeira linha.",
      "mensagem_sucesso": "Arquivo {nome_arquivo}.csv carregado com sucesso. Estrutura e cabeçalhos validados.",
      "impacto_sistema": "Libera o arquivo para leitura pelo motor de regras."
    },
    {
      "categoria": "Upload de Lote",
      "regra": "Padrão de Datas e Decimais",
      "condicao_sucesso": "Datas no formato dd/mm/aaaa e valores com vírgula para casas decimais.",
      "mensagem_sucesso": "Formatação de datas e valores monetários reconhecida sem inconsistências.",
      "impacto_sistema": "Converte os campos para tipos numéricos e datas para validação."
    },
    {
      "categoria": "Elegibilidade",
      "regra": "Prazo Máximo de Vencimento",
      "condicao_sucesso": "Dias até o vencimento menores ou iguais ao parâmetro ativo em validadores_antecipe.json.",
      "mensagem_sucesso": "NF {nu_documento} · Prazo elegível: vence em {prazo_dias} dias (limite configurado: {limite_dias} dias).",
      "impacto_sistema": "Marca a regra como atendida no motor de regras."
    },
    {
      "categoria": "Elegibilidade",
      "regra": "Valor Mínimo da Nota",
      "condicao_sucesso": "VALOR_NOMINAL igual ou superior ao limite mínimo do fundo.",
      "mensagem_sucesso": "NF {nu_documento} · Valor aprovado: R$ {valor_nominal} cumpre o valor mínimo exigido de R$ {limite_minimo}.",
      "impacto_sistema": "Habilita a nota para o cálculo de desconto."
    },
    {
      "categoria": "Elegibilidade",
      "regra": "Concentração de Sacado",
      "condicao_sucesso": "Volume total do sacado (DOC_SACADO) não ultrapassa o teto permitido pelo fundo.",
      "mensagem_sucesso": "NF {nu_documento} · Limite do sacado disponível: {nome_sacado} com limite suficiente no fundo.",
      "impacto_sistema": "Permite a compra do título sem estourar a carteira."
    },
    {
      "categoria": "Elegibilidade",
      "regra": "Regularidade Cadastral",
      "condicao_sucesso": "CNPJ/CPF do sacado e do cedente ativos e regulares.",
      "mensagem_sucesso": "NF {nu_documento} · Situação cadastral regular para cedente e sacado.",
      "impacto_sistema": "Autoriza o prosseguimento da análise de cessão."
    },
    {
      "categoria": "Configuração",
      "regra": "Filtro de Validadores Ativos",
      "condicao_sucesso": "Considerar apenas validadores com chave ativo: true no JSON.",
      "mensagem_sucesso": "Regra {codigo} inativa ignorada na avaliação.",
      "impacto_sistema": "Impede recusas indevidas por critérios desativados pelo gestor."
    },
    {
      "categoria": "Integridade",
      "regra": "Unicidade no Estoque Histórico",
      "condicao_sucesso": "O título (NU_DOCUMENTO + DOC_CEDENTE) não consta nas 100 mil linhas de estoque_antecipe.csv.",
      "mensagem_sucesso": "NF {nu_documento} · Título inédito: nenhum registro de aquisição prévia encontrado na carteira.",
      "impacto_sistema": "Garante que o recebível não foi comprado anteriormente."
    },
    {
      "categoria": "Integridade",
      "regra": "Unicidade no Lote Atual",
      "condicao_sucesso": "A nota aparece apenas uma vez no arquivo CSV submetido.",
      "mensagem_sucesso": "NF {nu_documento} · Documento único no lote submetido.",
      "impacto_sistema": "Evita compra duplicada de notas dentro da mesma remessa."
    },
    {
      "categoria": "Integridade",
      "regra": "Idempotência de Processamento",
      "condicao_sucesso": "Reenvio do mesmo lote/requisição detectado sem gerar duplicações na base.",
      "mensagem_sucesso": "Lote já processado anteriormente. Exibindo os resultados consolidados da simulação original.",
      "impacto_sistema": "Devolve a resposta em cache ou estado consistente sem recriar registros."
    },
    {
      "categoria": "Financeiro",
      "regra": "Cálculo de Preço Individual",
      "condicao_sucesso": "Aplicação da taxa de desconto simples sobre o valor de face da nota aprovada.",
      "mensagem_sucesso": "Simulação · NF {nu_documento}: Valor de face R$ {valor_nominal} ➔ Valor líquido: R$ {valor_liquido}",
      "impacto_sistema": "Exibe o valor líquido descontado na tabela e no payload JSON."
    },
    {
      "categoria": "Financeiro",
      "regra": "Consolidação do Lote",
      "condicao_sucesso": "Soma do valor líquido de todas as notas que obtiveram status de Aprovada.",
      "mensagem_sucesso": "Lote avaliado: {total_aprovadas} notas aprovadas. Total a receber: R$ {total_liquido}.",
      "impacto_sistema": "Apresenta o card de total geral na tela e no resumo da API."
    }
  ],
  "prototipo_interface_resultados": [
    {
      "componente": "Cabeçalho de Upload",
      "entrada_regra": "Arquivo CSV submetido",
      "formato_exibido": "Barra de progresso preenchida em verde com o nome lote-notas.csv",
      "comportamento": "Confirmação visual imediata do carregamento do lote."
    },
    {
      "componente": "Linha 1 da Tabela",
      "entrada_regra": "Nota que cumpre todos os validadores ativos (validadores_antecipe.json)",
      "formato_exibido": "NF 0142 | Loja Aurora | 30 dias | R$ 10.000 | Aprovada",
      "comportamento": "Badge verde de aprovação; elegível para a simulação financeira."
    },
    {
      "componente": "Linha 2 da Tabela",
      "entrada_regra": "Nota cujo prazo ultrapassa o parâmetro do validador (ex.: limite de 60 dias)",
      "formato_exibido": "NF 0157 | Mercado Sol | 90 dias | R$ 4.500 | Recusada",
      "comportamento": "Badge vermelho de recusa; aciona a caixa de justificativa contextual."
    },
    {
      "componente": "Linha 3 da Tabela",
      "entrada_regra": "Nota aprovada com prazo intermediário",
      "formato_exibido": "NF 0163 | Café Brisa | 45 dias | R$ 2.300 | Aprovada",
      "comportamento": "Badge verde de aprovação."
    },
    {
      "componente": "Banner de Recusa (Abaixo da Tabela)",
      "entrada_regra": "Justificativa da regra violada comparando dado real vs. parâmetro configurado",
      "formato_exibido": "Caixa de destaque com fundo claro e texto explicativo",
      "comportamento": "Exibe mensagem contextualizada: 'NF 0157 · Prazo acima do limite: vence em 90 dias; o limite configurado é 60.'"
    },
    {
      "componente": "Card de Simulação (Inferior)",
      "entrada_regra": "Valor de face menos taxa de desconto da compra",
      "formato_exibido": "Barra em verde escuro com valor líquido final",
      "comportamento": "Exibe totalização: 'Simulação · NF 0142 ➔ R$ 9.800'"
    }
  ],
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
