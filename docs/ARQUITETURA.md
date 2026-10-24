# Arquitetura - Hackathon Antecipe (KANASTRA)

## Visão Geral
Sistema para análise de recebíveis a prazo (Antecipe). Empresa vende notas para FIDC. FIDC avalia elegibilidade por regras configuráveis e simula valor líquido.

## Stack
- **Frontend:** SPA separado (React/Vue/Svelte - decidiremos, mas estrutura genérica)
- **Backend API:** Ruby on Rails (API mode) + PostgreSQL
- **Processamento pesado:** C++ como extensão nativa Ruby via FFI (Rice/C API) - mais ágil e menor custo
- **Regras:** Motor dinâmico lendo `arquivos/validadores_antecipe.json` (sem hardcode)
- **Idempotência/Hash:** Hash por chave composta `NU_DOCUMENTO|DOC_CEDENTE`

## Divisão de Responsabilidades

### Frontend (SPA)
Responsável APENAS por erros estruturais do CSV:
- Verificação de separador `;`
- Verificação de encoding UTF-8
- Verificação de cabeçalho obrigatório
- Verificação de formato de datas `dd/mm/aaaa`
- Verificação de formato numérico com vírgula decimal
- Interface interativa para correção quando aplicável
- Split do CSV em chunks menores e envio ao backend

### Backend Rails
- Orquestração, upload/chunks, rate limit, CORS, validação de upload
- Persistência em PostgreSQL (migrations bem pensadas)
- Chamada da extensão C++ via FFI
- Armazenamento de resultados com hash por `NU_DOCUMENTO|DOC_CEDENTE`
- API para consulta de resultados
- Logs estruturados sem dados sensíveis

### C++ Core (extensão nativa)
- Processa chunks de CSV já validados estruturalmente
- Lê motor de regras dinâmico do `validadores_antecipe.json`
- Verifica duplicados contra `estoque_antecipe.csv` (estoque histórico)
- Verifica duplicados dentro do lote
- Aplica validadores: PRAZO_MAXIMO, VALOR_MINIMO, CONCENTRACAO_SACADO, SITUACAO_CADASTRAL
- Calcula desconto simples e valor líquido
- Gera explicação clara para recusas
- Envia resultados processados para gravação no banco (ou retorna para Rails gravar)
- Alta performance para 100k-500k linhas
- Sem logs com dados sensíveis

## Fluxo
1. Frontend valida estrutura CSV, corrige erros estruturais interativamente
2. Frontend divide em chunks e envia para Rails API
3. Rails recebe chunk, valida upload, aplica rate limit/CORS
4. Rails passa chunk para extensão C++ via FFI
5. C++ processa: carrega regras, verifica estoque, aplica validadores, calcula
6. C++ retorna resultados ou Rails insere no Postgres com hash `NU_DOCUMENTO|DOC_CEDENTE`
7. Resultados ficam disponíveis para consulta com totalização

## Segurança
- Sem chaves/segredos no código
- Rate limiting
- CORS configurado
- Validação de upload (tipo/tamanho)
- Logs estruturados sem dados sensíveis
- Mascaramento de dados
- Verificação OWASP/CVE nas dependências
- Criptografia conforme necessário

## Performance
- Processamento em chunks
- Hash para retorno rápido e idempotência
- C++ nativo para regras/calculos
- PostgreSQL com índices apropriados
- Preparado para 100k-500k linhas (meta 700k requisições nos testes)
