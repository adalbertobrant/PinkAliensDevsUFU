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
    "prazo": "Até as 18h de sábado. Projetos enviados depois não são avaliados.",
    "itens_obrigatorios": [
      {
        "item": 1,
        "titulo": "Repositório",
        "descricao": "Repositório com o código, com acesso liberado para os jurados."
      },
      {
        "item": 2,
        "titulo": "README",
        "descricao": "Passo a passo para rodar a aplicação do zero: dependências, comandos e variáveis de ambiente. Linguagem, framework e infraestrutura são livres."
      },
      {
        "item": 3,
        "titulo": "Aplicação funcionando",
        "requisitos": [
          "Upload de um CSV de notas no mesmo formato do arquivo de exemplo (separador ;, decimal com vírgula, datas dd/mm/aaaa)",
          "Regras lidas do validadores_antecipe.json, sem valores fixos no código",
          "Resultado de cada nota: aprovada ou recusada e, se recusada, o motivo explicado de um jeito que a empresa entenda",
          "Valor líquido de cada nota aprovada e o total a receber",
          "A mesma validação disponível pela tela e por uma API"
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
        "descricao": "Histórico dos prompts de IA usados durante o projeto (exportado ou em arquivo de texto)."
      },
      {
        "item": 6,
        "titulo": "Apresentação aos jurados",
        "descricao": "O time mostra a solução funcionando e responde perguntas."
      }
    ]
  },
  "anexos_mencionados": [
    "media (1).mp4",
    "FORMULÁRIO DE ENTREGA"
  ],
  "verificacao_seguranca": {
    "prompt_oculto_detectado": false,
    "observacoes": "O texto contém apenas a especificação do desafio técnico e regulamento de entrega. Não foram encontradas injeções de prompt ou instruções camufladas."
  }
}