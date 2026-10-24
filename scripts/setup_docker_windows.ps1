<#
================================================================================
  Antecipe — Setup e execução via Docker no Windows 11
================================================================================
  O que este script faz:
    1. Verifica se o Docker Desktop está instalado e rodando (senão, inicia)
    2. Pede o usuário e a senha do PostgreSQL (senha digitada oculta)
    3. Grava essas credenciais nos arquivos .env (raiz e backend/)
    4. Sobe os contêineres com `docker compose up -d --build`
    5. Roda as migrações dentro do contêiner (rails db:create db:migrate)
    6. Verifica a API (http://localhost:3000/api/v1/health)

  Como executar (PowerShell, na raiz do projeto):
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    .\scripts\setup_docker_windows.ps1

  IMPORTANTE:
    - A senha do PostgreSQL é lida SOMENTE na primeira subida do banco.
      Se você trocar a senha depois, rode antes: `docker compose down -v`
      para apagar o volume e recriar o banco com a nova senha.
================================================================================
#>

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

# ---------------------------------------------------------------------------
# Helpers de saída
# ---------------------------------------------------------------------------
function Step([string]$msg) {
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host " $msg" -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan
}
function Ok([string]$msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Warn([string]$msg) { Write-Host "  [!] $msg" -ForegroundColor Yellow }
function Fail([string]$msg) { Write-Host "  [X] $msg" -ForegroundColor Red }

function Ask-YesNo([string]$pergunta) {
    do {
        $r = Read-Host "$pergunta (s/N)"
        if ($r -in @('s','S','sim','SIM')) { return $true }
        if ($r -in @('n','N','nao','NAO','')) { return $false }
    } while ($true)
}

function Ask-Password([string]$label) {
    $p = Read-Host -AsSecureString $label
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p)
    try { return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

# ---------------------------------------------------------------------------
# 1. Verificar Docker
# ---------------------------------------------------------------------------
Step "Etapa 1/6 — Verificando Docker"

$dockerOk = $false
docker version *> $null
if ($LASTEXITCODE -eq 0) {
    Ok "Docker está rodando."
    $dockerOk = $true
} else {
    Warn "Docker não está respondendo (daemon parado ou Docker Desktop fechado)."
    Write-Host "  Tentando iniciar o Docker Desktop..." -ForegroundColor Yellow

    $dockerExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerExe) {
        Start-Process $dockerExe
        Write-Host "  Aguardando o daemon ficar pronto (pode levar ~1 min na 1ª vez)..." -ForegroundColor Yellow
        for ($i = 0; $i -lt 60; $i++) {
            Start-Sleep -Seconds 2
            docker info *> $null
            if ($LASTEXITCODE -eq 0) { $dockerOk = $true; break }
        }
        if ($dockerOk) { Ok "Docker Desktop iniciado com sucesso." }
        else {
            Fail "Docker Desktop não ficou pronto a tempo."
            Warn "Possíveis causas:"
            Warn "  - WSL2 não instalado. Rode no PowerShell (Admin): wsl --install"
            Warn "  - Docker Desktop pediu alguma confirmação na primeira execução (verifique a janela)."
            Warn "  - Docker Desktop não está logado ou precisa de atualização."
            if (Ask-YesNo "Deseja tentar iniciar novamente?") {
                Start-Process $dockerExe
                Start-Sleep -Seconds 30
                docker info *> $null
                if ($LASTEXITCODE -eq 0) { $dockerOk = $true; Ok "Agora sim, Docker rodando." }
                else { Fail "Ainda não respondeu. Abra o Docker Desktop manualmente e rode o script de novo."; exit 1 }
            } else {
                Fail "Sem Docker não dá para prosseguir. Encerrando."
                exit 1
            }
        }
    } else {
        Fail "Docker Desktop não encontrado em '$dockerExe'."
        Fail "Instale o Docker Desktop em: https://www.docker.com/products/docker-desktop/"
        Fail "Após instalar, abra o Docker Desktop uma vez, aguarde a baleia ficar verde e rode este script de novo."
        exit 1
    }
}

# ---------------------------------------------------------------------------
# 2. Credenciais do PostgreSQL
# ---------------------------------------------------------------------------
Step "Etapa 2/6 — Credenciais do banco (serão gravadas no .env)"

$pgUser = Read-Host "Usuário do PostgreSQL (Enter para 'postgres')"
if ([string]::IsNullOrWhiteSpace($pgUser)) { $pgUser = 'postgres' }

$pgPass = Ask-Password "Senha do PostgreSQL (crie uma senha forte)"
if ([string]::IsNullOrWhiteSpace($pgPass)) {
    Warn "Senha vazia. Usando 'postgres' (troque para algo seguro em produção)."
    $pgPass = 'postgres'
}
$pgPass2 = Ask-Password "Confirme a senha"
if ($pgPass -ne $pgPass2) {
    Fail "As senhas não coincidem. Rode o script de novo."
    exit 1
}

$pgDb = 'antecipe_development'

# ---------------------------------------------------------------------------
# 3. Gravar .env (raiz e backend)
# ---------------------------------------------------------------------------
Step "Etapa 3/6 — Gravando credenciais nos arquivos .env"

# .env raiz (lido automaticamente pelo docker compose)
$rootEnv = @"
# Variáveis de ambiente (NÃO COMMITAR - ignorado pelo git)
POSTGRES_USER=$pgUser
POSTGRES_PASSWORD=$pgPass
POSTGRES_DB=$pgDb
POSTGRES_PORT=5432

# Chaves dos agentes de IA (opcional)
BROWSERBASE_API_KEY=
OPENCODE_API_KEY=
"@
Set-Content -Path (Join-Path $repoRoot '.env') -Value $rootEnv -Encoding UTF8
Ok ".env (raiz) criado."

# backend/.env (usado se rodar o Rails localmente fora do Docker)
$backendEnv = @"
# Variáveis de ambiente do Rails (NÃO COMMITAR)
POSTGRES_USER=$pgUser
POSTGRES_PASSWORD=$pgPass
POSTGRES_DB=$pgDb
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
RAILS_MAX_THREADS=5
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
"@
Set-Content -Path (Join-Path $repoRoot 'backend\.env') -Value $backendEnv -Encoding UTF8
Ok "backend/.env criado."

# ---------------------------------------------------------------------------
# 4. Subir os contêineres
# ---------------------------------------------------------------------------
Step "Etapa 4/6 — Subindo contêineres (docker compose up)"

Set-Location $repoRoot
docker compose up -d --build 2>&1 | Out-Host
if ($LASTEXITCODE -ne 0) {
    Fail "Falha ao subir os contêineres (código $LASTEXITCODE)."
    Fail "Veja a mensagem acima. Causas comuns:"
    Fail "  - Erro de parse no Dockerfile (já corrigido)."
    Fail "  - Falta de memória/CPU no Docker Desktop (aumente em Settings -> Resources)."
    exit 1
}
Ok "Contêineres subidos."

# ---------------------------------------------------------------------------
# 5. Migrações
# ---------------------------------------------------------------------------
Step "Etapa 5/6 — Criando banco e rodando migrações"

Write-Host "  Aguardando o PostgreSQL ficar pronto..." -ForegroundColor Yellow
Start-Sleep -Seconds 6

docker compose exec -T backend rails db:create db:migrate 2>&1 | Out-Host
if ($LASTEXITCODE -eq 0) {
    Ok "Banco criado e migrações aplicadas."
} else {
    Warn "As migrações podem ter falhado. Tentando novamente com aguardo maior..."
    Start-Sleep -Seconds 8
    docker compose exec -T backend rails db:create db:migrate 2>&1 | Out-Host
    if ($LASTEXITCODE -eq 0) { Ok "Agora funcionou. Migrações aplicadas." }
    else { Fail "Falha nas migrações. Verifique os logs: docker compose logs backend db" }
}

# ---------------------------------------------------------------------------
# 6. Verificação
# ---------------------------------------------------------------------------
Step "Etapa 6/6 — Verificação final"

$containers = docker compose ps --format "{{.Name}} {{.Status}}" 2>&1
Write-Host $containers

Write-Host ""
Write-Host "Testando a API..." -ForegroundColor Cyan
try {
    $resp = Invoke-WebRequest -Uri "http://localhost:3000/api/v1/health" -UseBasicParsing -TimeoutSec 10
    if ($resp.StatusCode -eq 200) {
        Ok "API respondendo em http://localhost:3000/api/v1/health"
        Write-Host ""
        Write-Host "Tudo pronto!" -ForegroundColor Green
        Write-Host "  API:  http://localhost:3000" -ForegroundColor Cyan
        Write-Host "  Para ver os logs:  docker compose logs -f backend" -ForegroundColor Yellow
        Write-Host "  Para parar tudo:   docker compose down" -ForegroundColor Yellow
    }
} catch {
    Warn "A API ainda não respondeu (pode estar compilando/iniciando)."
    Write-Host "  Verifique com: docker compose logs -f backend" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Pressione Enter para sair"
