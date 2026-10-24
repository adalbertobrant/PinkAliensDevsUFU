#!/usr/bin/env bash
# Limpa as tabelas do banco Antecipe (PostgreSQL no Docker).
#
# Uso:
#   ./scripts/limpar_banco.sh          # limpa só lotes/recebiveis (testes)
#   ./scripts/limpar_banco.sh --tudo   # limpa também estoque e situação cadastral
set -e

CONTAINER="${CONTAINER:-pinkaliensdevsufu-db-1}"
DB="${DB:-antecipe_development}"
USER="${PGUSER:-postgres}"

if [ "$1" = "--tudo" ]; then
  TABELAS="recebiveis, lotes, estoques, situacao_cadastrais"
  echo "Limpando TODAS as tabelas ($TABELAS)..."
else
  TABELAS="recebiveis, lotes"
  echo "Limpando lotes e recebíveis ($TABELAS)..."
fi

docker exec "$CONTAINER" psql -U "$USER" -d "$DB" -c "TRUNCATE $TABELAS CASCADE;"

echo "=== Estado do banco ==="
docker exec "$CONTAINER" psql -U "$USER" -d "$DB" -c \
  "SELECT (SELECT COUNT(*) FROM lotes) AS lotes, (SELECT COUNT(*) FROM recebiveis) AS recebiveis, (SELECT COUNT(*) FROM estoques) AS estoques, (SELECT COUNT(*) FROM situacao_cadastrais) AS situacoes;"
