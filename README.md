# PinkAliensDevsUFU - ANTECIPE

## Hackathon KANASTRA - Desafio Antecipe

### Integrantes

- [Adalberto Brant](https://github.com/adalbertobrant)

### Sobre o Desafio

Uma pequena empresa vendeu a prazo e quer o dinheiro hoje. Ela 'vende' essas notas para o fundo, mas o fundo só pode comprar o que cumpre regras: prazo máximo, valor mínimo, sacado não pode estar concentrado demais, CNPJ ativo etc.

### Arquitetura da Aplicação

```
PinkAliensDevsUFU/
├── frontend/          # SPA separado (validação estrutural CSV apenas)
├── backend/           # Rails API + PostgreSQL
├── cpp_core/          # Extensão C++ nativa via FFI/Rice (motor de regras)
├── arquivos/          # Dados (estoque_antecipe.csv, validadores_antecipe.json, resultado_esperado_100k.json)
├── testes/            # Testes rápidos Ruby/C++ e testes de carga
├── PROMPT_HISTORY/    # Histórico cronológico de prompts IA (JSON)
└── docker-compose.yml
```

#### Blocos da Aplicação

```text
[Frontend SPA] -> validação estrutural CSV (separador ;, encoding UTF-8, cabeçalho, datas dd/mm/aaaa, decimal ,)
                -> divide em chunks
                -> POST /api/v1/lotes

[Backend Rails API] -> rate limit, CORS, validação upload
                   -> chama extensão C++ via FFI
                   -> persiste resultados no PostgreSQL com hash

[C++ Core Extension] -> lê validadores_antecipe.json (dinâmico, sem hardcode)
                     -> verifica estoque_antecipe.csv (já vendido)
                     -> verifica duplicados no lote
                     -> aplica validadores: PRAZO_MAXIMO, VALOR_MINIMO, CONCENTRACAO_SACADO, SITUACAO_CADASTRAL
                     -> calcula desconto simples e valor líquido
                     -> gera explicação clara para recusas
                     -> hash por NU_DOCUMENTO|DOC_CEDENTE
```

### Tecnologias Utilizadas

- **Frontend:** SPA (JavaScript) - Validação estrutural apenas
- **Backend:** Ruby on Rails 8 (API mode)
- **Banco de Dados:** PostgreSQL
- **Processamento Pesado:** C++ (extensão nativa Ruby via Rice/FFI)
- **Segurança:** Rack::Attack (rate limit), Rack::CORS
- **Containerização:** Docker, Docker Compose

### Como Executar

#### Com Docker (Recomendado)

```bash
# Clonar repositório
git clone https://github.com/adalbertobrant/PinkAliensDevsUFU.git
cd PinkAliensDevsUFU

# Configurar variáveis de ambiente (senhas NÃO vão para o git)
cp .env.example .env
# Edite .env e defina uma senha forte para POSTGRES_PASSWORD

# Subir serviços
docker-compose up --build

# Em outro terminal, executar migrations
docker-compose exec backend rails db:create db:migrate
```

#### Sem Docker (Linux)

**Pré-requisitos:**
- Ruby 3.3+
- PostgreSQL 16
- Node.js
- Build tools (g++, make, cmake)
- libpq-dev, libjsoncpp-dev

```bash
# Configurar banco
cd backend
cp .env.example .env
# Edite .env e defina uma senha forte para POSTGRES_PASSWORD

# Instalar dependências
bundle install

# Compilar extensão C++
cd ext/antecipe_core
ruby extconf.rb
make
cd ../..

# Criar e migrar banco
rails db:create db:migrate

# Iniciar servidor
rails server
```

### API Endpoints

- `GET /api/v1/health` - Health check
- `POST /api/v1/lotes` - Upload de chunk CSV validado
- `GET /api/v1/lotes` - Listar lotes
- `GET /api/v1/lotes/:id` - Detalhes do lote com recebíveis

### Formato CSV

- **Separador:** `;` (ponto e vírgula)
- **Decimal:** `,` (vírgula)
- **Datas:** `dd/mm/aaaa`
- **Encoding:** UTF-8
- **Cabeçalho:** Obrigatório

**Colunas obrigatórias:**
NOME_FUNDO, DOC_FUNDO, NOME_CEDENTE, DOC_CEDENTE, NOME_SACADO, DOC_SACADO, NU_DOCUMENTO, TIPO_RECEBIVEL, VALOR_NOMINAL, DATA_VENCIMENTO_ORIGINAL, DATA_AQUISICAO

### Regras de Negócio

Motor de regras dinâmico lendo `arquivos/validadores_antecipe.json`:
- **PRAZO_MAXIMO:** Prazo até vencimento
- **VALOR_MINIMO:** Valor mínimo da nota
- **CONCENTRACAO_SACADO:** Concentração por sacado
- **SITUACAO_CADASTRAL:** Regularidade cadastral

### Integridade
- **Hash por chave:** `NU_DOCUMENTO|DOC_CEDENTE`
- **Estoque histórico:** Verifica em `arquivos/estoque_antecipe.csv`
- **Duplicados no lote:** Detectados e rejeitados
- **Idempotência:** Lotes com mesmo hash não são reprocessados

### Testes

```bash
# Testes Ruby rápidos
cd testes/ruby && ruby hash_test.rb

# Testes de carga (k6)
k6 run testes/carga/k6_test.js
```

### Histórico de Prompts IA

Todos os prompts utilizados estão registrados em ordem cronológica em [`PROMPT_HISTORY/prompts.json`](/PROMPT_HISTORY/prompts.json) com: descrição, site/ação, agente responsável, sha do commit, avaliação de custo e quantidade de tokens.

### Possíveis Erros e Soluções

| Erro | Causa | Solução |
|---|---|---|
| ERR_CSV_SEPARATOR | Separador incorreto | Usar ponto e vírgula (;) |
| ERR_CSV_NUMERIC_FORMAT | Ponto ao invés de vírgula decimal | Usar vírgula para casas decimais |
| ERR_CSV_DATE_FORMAT | Formato de data errado | Usar dd/mm/aaaa |
| ERR_CSV_HEADER_MISSING | Cabeçalho ausente/incompleto | Verificar colunas obrigatórias |
| ERR_CSV_ENCODING | Encoding incorreto | Salvar como UTF-8 |

### Abrir Issues

Para reportar problemas ou sugestões, abra uma issue em: https://github.com/adalbertobrant/PinkAliensDevsUFU/issues

### Segurança
- Sem chaves/segredos no código-fonte
- **Senhas e segredos ficam apenas em `.env`** (arquivo ignorado pelo git — nunca commitar)
- Logs estruturados sem dados sensíveis do CSV
- Rate limiting configurado
- CORS configurado
- Validação de upload
- Criptografia e boas práticas OWASP

### Variáveis de Ambiente

As senhas e segredos **não** ficam versionados. Use os arquivos de exemplo como modelo:

| Arquivo | Objetivo |
|---|---|
| `.env.example` | Modelo para o `docker-compose` (Postgres + chaves de agentes) |
| `backend/.env.example` | Modelo para o Rails (dotenv-rails carrega automaticamente) |

```bash
# Configure uma vez:
cp .env.example .env           # e preencha POSTGRES_PASSWORD com senha forte
cp backend/.env.example backend/.env
```

> O `backend/config/master.key` e os arquivos `.env` estão no `.gitignore` e nunca são commitados.
