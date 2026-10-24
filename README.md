# PinkAliensDevsUFU - ANTECIPE

## Hackathon KANASTRA - Desafio Antecipe

### Integrantes

- [Hemilinei Talita Dal Santo](https://github.com/Hemi-DalSanto)

- [Jailce Fernanda](https://github.com/jailce)

- [Adalberto Brant](https://github.com/adalbertobrant)



### Sobre o Desafio

Uma pequena empresa vendeu a prazo e quer o dinheiro hoje. Ela "vende" essas notas para o fundo, mas o fundo só pode comprar o que cumpre regras: prazo máximo, valor mínimo, sacado não pode estar concentrado demais, CNPJ ativo etc.

### Arquitetura da Aplicação

```
PinkAliensDevsUFU/
├── frontend/          # SPA separado (validação estrutural CSV apenas)
├── backend/           # Rails API + PostgreSQL
├── cpp_core/          # Motor de regras C++ (engine.hpp) + harness de teste (main.cpp)
├── arquivos/          # Dados (estoque_antecipe.csv, cnpj_situacao_mock.csv,
│                      #   validadores_antecipe.json, resultado_esperado_100k.json)
├── testes/            # Testes Ruby (regressão do motor) e carga (k6)
├── PROMPT_HISTORY/    # Histórico cronológico de prompts IA (JSON)
└── docker-compose.yml
```

#### Blocos da Aplicação

```text
[Frontend SPA] -> validação estrutural CSV (separador ;, encoding UTF-8,
                  cabeçalho, datas dd/mm/aaaa, decimal ,)
                -> divide em chunks
                -> POST /api/v1/lotes

[Backend Rails API] -> rate limit, CORS, validação de upload
                    -> chama extensão C++ via FFI (Rice)
                    -> persiste resultados no PostgreSQL com hash

[C++ Core] -> lê validadores_antecipe.json (dinâmico, sem hardcode)
            -> carrega estoque_antecipe.csv e cnpj_situacao_mock.csv em memória
            -> aplica validadores: TIPO_RECEBIVEL, PRAZO_MAXIMO, VALOR_MINIMO,
               CONCENTRACAO_MAXIMA_SACADO, SITUACAO_CADASTRAL_SACADO
            -> calcula desconto simples e valor líquido
            -> gera explicação clara para recusas
```

### Tecnologias Utilizadas

- **Frontend:** SPA (JavaScript) — validação estrutural apenas
- **Backend:** Ruby on Rails 8 (API mode)
- **Banco de Dados:** PostgreSQL
- **Processamento pesado:** C++ (extensão nativa Ruby via Rice/FFI)
- **Segurança:** Rack::Attack (rate limit), Rack::CORS
- **Containerização:** Docker, Docker Compose

### Como Executar

#### Com Docker (Recomendado)

**Linux/macOS — manual:**

```bash
# Clonar repositório
git clone https://github.com/adalbertobrant/PinkAliensDevsUFU.git
cd PinkAliensDevsUFU

# Configurar variáveis de ambiente (senhas NÃO vão para o git)
cp .env.example .env
# Edite .env e defina uma senha forte para POSTGRES_PASSWORD

# Subir serviços
docker compose up --build

# Em outro terminal, executar migrations
docker compose exec backend rails db:create db:migrate
```

#### Sem Docker (Linux)

**Pré-requisitos:**
- Ruby 3.3+
- PostgreSQL 16
- Node.js
- Build tools (g++, make)

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

### Como Usar (via web / navegador)

O sistema tem uma interface web simples (SPA) em `frontend/`. Para usar:

**1. Suba o backend** (um dos caminhos abaixo):
```bash
# Via Docker (sobe banco + API):
docker compose up --build

# Ou local, sem Docker:
cd backend && bundle exec rails server
```

**2. Sirva o frontend** (o `index.html` usa módulos ES, então precisa de um servidor HTTP estático — abrir direto com `file://` pode ser bloqueado pelo navegador):
```bash
# Opção A — Python (vem no Linux/macOS; no Windows use py ou o npx)
cd frontend && python3 -m http.server 8080

# Opção B — Node/npx
cd frontend && npx serve .
```
Abra no navegador: **http://localhost:8080**

**3. Use a aplicação:**
1. Selecione um arquivo `.csv` de notas (formato abaixo).
2. A aplicação valida a **estrutura**:
   - Se houver erros (separador, data, decimal, cabeçalho), mostra um **relatório** com os erros e um botão **"Baixar CSV dos registros com erro"** para você corrigir.
   - Se a estrutura estiver correta, envia automaticamente ao backend.
3. O backend processa as **regras de negócio** e retorna a tabela de resultados: notas **Aprovadas** (com valor líquido) e **Recusadas** (com o motivo), além do **total a receber**.

> 💡 O campo **"API"** na tela permite apontar para outro endereço do backend (padrão `http://localhost:3000`).

### API Endpoints

- `GET  /api/v1/health` — health check
- `POST /api/v1/lotes` — processa um lote CSV (corpo JSON com `conteudo` e `nome_arquivo`)
- `GET  /api/v1/lotes` — lista lotes
- `GET  /api/v1/lotes/:id` — detalhes de um lote com recebíveis

Exemplo de requisição:

```bash
curl -X POST http://localhost:3000/api/v1/lotes \
  -H "Content-Type: application/json" \
  -d '{"nome_arquivo":"lote.csv","conteudo":"NOME_FUNDO;DOC_FUNDO;...;DATA_AQUISICAO\n..."}'
```

### Formato CSV

- **Separador:** `;` (ponto e vírgula)
- **Decimal:** `,` (vírgula)
- **Datas:** `dd/mm/aaaa`
- **Encoding:** UTF-8
- **Cabeçalho:** obrigatório

**Colunas obrigatórias:**
`NOME_FUNDO`, `DOC_FUNDO`, `NOME_CEDENTE`, `DOC_CEDENTE`, `NOME_SACADO`, `DOC_SACADO`, `NU_DOCUMENTO`, `TIPO_RECEBIVEL`, `VALOR_NOMINAL`, `DATA_VENCIMENTO_ORIGINAL`, `DATA_AQUISICAO`

### Regras de Negócio

O motor de regras lê `arquivos/validadores_antecipe.json` (sem valores fixos no código). As regras ativas são:

| Validador | Regra |
|---|---|
| `TIPO_RECEBIVEL` | apenas `Duplicata` e `Duplicata de Serviço` são elegíveis |
| `PRAZO_MAXIMO` | prazo do título (vencimento − aquisição) ≤ `limite_dias` (180) |
| `VALOR_MINIMO` | valor nominal ≥ `limite_minimo` (R$ 100,00) |
| `CONCENTRACAO_MAXIMA_SACADO` | sacado (raiz CNPJ) ≤ `limite_percentual` (10%) do total do fundo |
| `SITUACAO_CADASTRAL_SACADO` | situação do CNPJ do sacado deve ser `ATIVA` (fonte: `cnpj_situacao_mock.csv`) |

Cada nota aprovada recebe o **valor líquido** = valor de face × (1 − taxa de desconto).

### Integridade

No fluxo real de submissão (`checar_integridade: true`), o motor aplica duas checagens adicionais:

| Código | Regra |
|---|---|
| `ERR_STOCK_ALREADY_SOLD` | título (`NU_DOCUMENTO|DOC_CEDENTE`) já consta no estoque histórico |
| `ERR_BATCH_DUPLICATE` | mesma chave aparece mais de uma vez no lote submetido |

- **Hash por chave:** `SHA256(NU_DOCUMENTO|DOC_CEDENTE)` para unicidade
- **Idempotência:** lotes com mesmo hash não são reprocessados
- **Estoque histórico:** `arquivos/estoque_antecipe.csv` carregado em memória (base da detecção de títulos já negociados)
- **Situação cadastral:** `arquivos/cnpj_situacao_mock.csv` como fonte de verdade (hasheada e consultada pelo motor)

> Nota: o gabarito (`resultado_esperado_100k.json`) avalia apenas as regras de negócio, por isso o teste de regressão usa `checar_integridade: false`.

### Importar dados no banco (rake tasks)

O motor C++ lê os dados direto dos arquivos em memória (rápido). Para persistir/consultar no PostgreSQL, use as tarefas:

```bash
cd backend

# Situação cadastral (3041 registros — rápido)
rails antecipe:import_cnpj_situacao

# Estoque histórico (100 mil linhas — pode demorar alguns minutos)
rails antecipe:import_estoque
```

Os CNPJs são normalizados (removida a pontuação) e armazenados com hash `SHA256` na tabela `situacao_cadastrais`; o estoque vai para `estoques` com `hash_chave = SHA256(NU_DOCUMENTO|DOC_CEDENTE)`.

### Performance

O motor C++ processa **100.554 linhas em ~0,3s** (bem abaixo do requisito de 1 minuto), usando `unordered_map`/`unordered_set` para lookups O(1) e processamento em dois passos (agregação + avaliação).

### Testes

```bash
# Teste de regressão do motor (valida as 4 regras estruturais contra o gabarito)
ruby testes/ruby/engine_test.rb

# Testes Ruby rápidos (hash)
ruby testes/ruby/hash_test.rb

# Compilar e rodar o motor standalone (C++)
g++ -O2 -std=c++17 -o /tmp/antecipe_engine cpp_core/main.cpp
/tmp/antecipe_engine

# Testes de carga (k6)
k6 run testes/carga/k6_test.js
```

### Histórico de Prompts IA

Todos os prompts utilizados estão registrados em ordem cronológica em [`PROMPT_HISTORY/prompts.json`](/PROMPT_HISTORY/prompts.json) com: descrição, site/ação, agente responsável, sha do commit, avaliação de custo e quantidade de tokens.

### Possíveis Erros e Soluções

#### Erros de CSV (estrutura do arquivo)

| Erro | Causa | Solução |
|---|---|---|
| `ERR_CSV_SEPARATOR` | Separador incorreto | Usar ponto e vírgula (;) |
| `ERR_CSV_NUMERIC_FORMAT` | Ponto ao invés de vírgula decimal | Usar vírgula para casas decimais |
| `ERR_CSV_DATE_FORMAT` | Formato de data errado | Usar dd/mm/aaaa |
| `ERR_CSV_HEADER_MISSING` | Cabeçalho ausente/incompleto | Verificar colunas obrigatórias |
| `ERR_CSV_ENCODING` | Encoding incorreto | Salvar como UTF-8 |


### Abrir Issues

Para reportar problemas ou sugestões, abra uma issue em: https://github.com/adalbertobrant/PinkAliensDevsUFU/issues

### Segurança

- Sem chaves/segredos no código-fonte
- **Senhas e segredos ficam apenas em `.env`** (arquivo ignorado pelo git — nunca commitar)
- Logs estruturados sem dados sensíveis do CSV
- Rate limiting configurado (Rack::Attack)
- CORS configurado (Rack::Cors)
- Validação de upload
- Boas práticas OWASP

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
