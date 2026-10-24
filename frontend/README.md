# Frontend SPA - Antecipe

SPA separado para o Hackathon Antecipe.

## Responsabilidades
- **APENAS validação estrutural do CSV** (conforme regras_agentes.md)
  - Separador ponto e vírgula (;)
  - Encoding UTF-8
  - Cabeçalho obrigatório
  - Formato de datas dd/mm/aaaa
  - Formato numérico com vírgula decimal
- Interface interativa para correção de erros estruturais
- Divisão do CSV em chunks menores
- Envio dos chunks para API Rails

## Regras de Negócio
As regras de negócio (PRAZO_MAXIMO, VALOR_MINIMO, CONCENTRAÇÃO_SACADO, SITUACAO_CADASTRAL), verificação de estoque, duplicados, cálculo financeiro são processados pelo **backend C++**.

## Estrutura
```
frontend/
├── validators/csv_structural.js  # Validador estrutural
├── utils/chunk_splitter.js        # Divisão em chunks
├── components/                    # Componentes UI
└── src/                          # Código principal
```
