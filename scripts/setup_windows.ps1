<#
================================================================================
  Antecipe — Setup de ambiente local no Windows 11 (sem Docker)
================================================================================
  O que este script faz, etapa por etapa:
    1. Verifica o que já está instalado (Ruby, PostgreSQL, Node, Git, MSYS2/build)
    2. Se algo estiver faltando/errado, AVISA e PERGUNTA se pode instalar
    3. Pede usuário e senha do PostgreSQL
    4. Gera o arquivo backend/.env com as credenciais (nunca commitado)
    5. Instala as gems (bundle install)
    6. Tenta compilar a extensão C++ (motor de regras)
    7. Cria o banco e roda as migrações (rails db:create db:migrate)
    8. Verifica o resultado de cada etapa antes de seguir

  Como executar (PowerShell):
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    .\scripts\setup_windows.ps1
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

# ---------------------------------------------------------------------------
# Helpers de verificação
# ---------------------------------------------------------------------------
function Test-Command([string]$cmd) {
    $null = Get-Command $cmd -ErrorAction SilentlyContinue
    return ($null -ne (Get-Command $cmd -ErrorAction SilentlyContinue))
}

function Get-Version([string]$cmd, [string]$args = '--version') {
    try { return (& $cmd $args 2>&1 | Select-Object -First 1) } catch { return $null }
}

# ---------------------------------------------------------------------------
# Helpers de interação
# ---------------------------------------------------------------------------
function Ask-YesNo([string]$pergunta) {
    do {
        $r = Read-Host "$pergunta (s/N)"
        if ($r -eq 's' -or $r -eq 'S' -or $r -eq 'sim' -or $r -eq 'SIM') { return $true }
        if ($r -eq 'n' -or $r -eq 'N' -or $r -eq 'nao' -or $r -eq 'NAO' -or $r -eq '') { return $false }
    } while ($true)
}

function Ask-Secret([string]$label) {
    $p = Read-Host $label
    return $p
}

function Ask-Password([string]$label) {
    $p = Read-Host -AsSecureString $label
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p)
    try { return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

# ---------------------------------------------------------------------------
# Instalação via winget (com confirmação)
# ---------------------------------------------------------------------------
function Install-Package([string]$nome, [string]$wingetId) {
    if (-not (Test-Command 'winget')) {
        Warn "O 'winget' (Windows Package Manager) não está disponível."
        Warn "Instale manualmente: $nome"
        return $false
    }
    if (Ask-YesNo "Deseja instalar $nome agora?") {
        Write-Host "  Instalando $nome via winget..." -ForegroundColor Yellow
        winget install --id $wingetId -e --accept-source-agreements --accept-package-agreements
        return $true
    }
    return $false
}

# ---------------------------------------------------------------------------
# 1. Verificação dos pré-requisitos
# ---------------------------------------------------------------------------
Step "Etapa 1/7 — Verificando pré-requisitos"

# Git
if (Test-Command 'git') {
    Ok "Git encontrado: $(Get-Version 'git' '--version')"
} else {
    Fail "Git não encontrado."
    if (Install-Package 'Git' 'Git.Git') { Warn "Reabra o PowerShell após instalar e rode o script de novo."; exit 0 }
}

# Ruby
$rubyOk = $false
if (Test-Command 'ruby') {
    $rubyVer = Get-Version 'ruby' '-v'
    Ok "Ruby encontrado: $rubyVer"
    $rubyOk = $true
} else {
    Fail "Ruby não encontrado."
    if (Install-Package 'Ruby (com DevKit/MSYS2)' 'RubyInstallerTeam.RubyWithDevKit.3.3') {
        Warn "IMPORTANTE: na instalação do Ruby, marque a opção 'Add Ruby executables to your PATH' e rode o 'MSYS2' (ridk install) quando solicitado."
        Warn "Após instalar, feche e reabra o PowerShell e rode o script novamente."
        exit 0
    } else {
        Warn "Ruby é obrigatório. Encerrando."
        exit 1
    }
}

# Node.js
if (Test-Command 'node') {
    Ok "Node.js encontrado: $(Get-Version 'node' '-v')"
} else {
    Warn "Node.js não encontrado (necessário apenas para o frontend)."
    $null = Install-Package 'Node.js LTS' 'OpenJS.NodeJS.LTS'
}

# PostgreSQL
$pgInstalado = $false
if (Test-Command 'psql') {
    Ok "PostgreSQL (psql) encontrado: $(Get-Version 'psql' '--version')"
    $pgInstalado = $true
} else {
    $pgService = Get-Service -Name 'postgresql*' -ErrorAction SilentlyContinue
    if ($pgService) {
        Ok "Serviço PostgreSQL encontrado: $($pgService.Name) ($($pgService.Status))"
        $pgInstalado = $true
    } else {
        Fail "PostgreSQL não encontrado."
        if (Install-Package 'PostgreSQL 16' 'PostgreSQL.PostgreSQL.16') {
            Warn "Durante a instalação do PostgreSQL, ANOTE a senha do usuário 'postgres' que você definir — vamos precisar dela a seguir."
            Warn "Após instalar, feche e reabra o PowerShell e rode o script novamente."
            exit 0
        } else {
            Warn "PostgreSQL é obrigatório. Encerrando."
            exit 1
        }
    }
}

# MSYS2 / build tools (g++ e make) — para compilar a extensão C++
$buildOk = $false
if ((Test-Command 'g++') -and (Test-Command 'make')) {
    Ok "Build tools encontrados (g++ e make)."
    $buildOk = $true
} elseif (Test-Command 'ridk') {
    Ok "DevKit (MSYS2) encontrado via RubyInstaller."
    $buildOk = $true
} else {
    Warn "Build tools (g++/make) não encontrados no PATH."
    Warn "A extensão C++ não será compilada; o sistema usará o modo de compatibilidade (mais lento)."
    $buildOk = $false
}

# ---------------------------------------------------------------------------
# 2. Credenciais do PostgreSQL
# ---------------------------------------------------------------------------
Step "Etapa 2/7 — Configurando credenciais do PostgreSQL"

$pgUser = Read-Host "Usuário do PostgreSQL (padrão: postgres)"
if ([string]::IsNullOrWhiteSpace($pgUser)) { $pgUser = 'postgres' }

$pgPass = Ask-Password "Senha do PostgreSQL (a que você definiu na instalação)"
if ([string]::IsNullOrWhiteSpace($pgPass)) {
    Warn "Senha vazia. Usando 'postgres' (recomendado trocar)."
    $pgPass = 'postgres'
}

# ---------------------------------------------------------------------------
# 3. Gerar arquivos .env
# ---------------------------------------------------------------------------
Step "Etapa 3/7 — Gerando arquivos de ambiente (.env)"

$backendDir = Join-Path $repoRoot 'backend'

# backend/.env
$envContent = @"
# Variáveis de ambiente do Rails (NÃO COMMITAR)
POSTGRES_USER=$pgUser
POSTGRES_PASSWORD=$pgPass
POSTGRES_DB=antecipe_development
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
RAILS_MAX_THREADS=5
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
"@
Set-Content -Path (Join-Path $backendDir '.env') -Value $envContent -Encoding UTF8
Ok "backend/.env criado com suas credenciais."

# .env raiz (para docker-compose, se um dia usar)
$rootEnv = @"
POSTGRES_USER=$pgUser
POSTGRES_PASSWORD=$pgPass
POSTGRES_DB=antecipe_development
POSTGRES_PORT=5432
BROWSERBASE_API_KEY=
OPENCODE_API_KEY=
"@
Set-Content -Path (Join-Path $repoRoot '.env') -Value $rootEnv -Encoding UTF8
Ok ".env (raiz) criado."

# ---------------------------------------------------------------------------
# 4. bundle install
# ---------------------------------------------------------------------------
Step "Etapa 4/7 — Instalando gems (bundle install)"

Push-Location $backendDir
try {
    bundle install
    if ($LASTEXITCODE -eq 0) { Ok "Gems instaladas com sucesso." }
    else { Warn "bundle install retornou código $LASTEXITCODE." }
} catch {
    Fail "Falha no bundle install: $_"
}
Pop-Location

# ---------------------------------------------------------------------------
# 5. Compilar extensão C++
# ---------------------------------------------------------------------------
Step "Etapa 5/7 — Compilando extensão C++ (motor de regras)"

if ($buildOk) {
    Push-Location (Join-Path $backendDir 'ext\antecipe_core')
    try {
        ruby extconf.rb 2>&1 | Out-Null
        if (Test-Path 'Makefile') {
            make 2>&1 | Out-Null
            if (Test-Path 'antecipe_core.so') {
                Copy-Item 'antecipe_core.so' (Join-Path $backendDir 'lib\antecipe_core.so') -Force
                Ok "Extensão C++ compilada (antecipe_core.so)."
            } else {
                Warn "Compilação não gerou o .so; usando modo de compatibilidade."
            }
        } else {
            Warn "Não foi possível gerar o Makefile; usando modo de compatibilidade."
        }
    } catch {
        Warn "Falha ao compilar C++: $_"
        Warn "O sistema funcionará no modo de compatibilidade (sem aceleração C++)."
    }
    Pop-Location
} else {
    Warn "Build tools ausentes — pulando compilação C++."
}

# ---------------------------------------------------------------------------
# 6. Criar banco e migrar
# ---------------------------------------------------------------------------
Step "Etapa 6/7 — Criando banco e rodando migrações"

# Garante que o serviço do PostgreSQL está rodando
$pgService = Get-Service -Name 'postgresql*' -ErrorAction SilentlyContinue
if ($pgService -and $pgService.Status -ne 'Running') {
    if (Ask-YesNo "O serviço $($pgService.Name) está parado. Iniciar agora?") {
        Start-Service $pgService.Name
        Ok "Serviço iniciado."
    }
}

Push-Location $backendDir
try {
    bundle exec rails db:create 2>&1 | Out-Host
    if ($LASTEXITCODE -eq 0) {
        Ok "Banco criado."
        bundle exec rails db:migrate 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) { Ok "Migrações aplicadas." }
        else { Fail "Falha ao migrar (código $LASTEXITCODE). Verifique senha e serviço do PostgreSQL." }
    } else {
        Fail "Falha ao criar banco. Verifique: (1) serviço PostgreSQL rodando, (2) usuário/senha corretos no backend/.env."
    }
} catch {
    Fail "Erro: $_"
}
Pop-Location

# ---------------------------------------------------------------------------
# 7. Verificação final
# ---------------------------------------------------------------------------
Step "Etapa 7/7 — Verificação final"

$ok = $true
if (-not (Test-Command 'ruby'))  { Fail "Ruby ausente."; $ok = $false }
if (-not (Test-Command 'bundle')) { Fail "Bundler ausente."; $ok = $false }
if (-not (Test-Command 'git'))    { Fail "Git ausente."; $ok = $false }
if (-not ($pgService -or (Test-Command 'psql'))) { Fail "PostgreSQL não detectado."; $ok = $false }

if ($ok) {
    Ok "Ambiente configurado com sucesso!"
    Write-Host ""
    Write-Host "Para iniciar o servidor Rails:" -ForegroundColor Cyan
    Write-Host "  cd backend" -ForegroundColor Yellow
    Write-Host "  bundle exec rails server" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "A API estará em http://localhost:3000/api/v1/health" -ForegroundColor Cyan
} else {
    Fail "Há itens pendentes. Revise as mensagens acima."
}

Write-Host ""
Read-Host "Pressione Enter para sair"
