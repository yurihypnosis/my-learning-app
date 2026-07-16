#!/usr/bin/env bash
# 本番 Supabase への読み書き。anon key は読み取り専用なので Management API を使う。
# `supabase db push` は使わないこと（このリポジトリのマイグレーションは適用済み分と
# 未適用分が混在しており、push は履歴を壊す）。
#
#   ./db.sh query "select ..."     -- SQL を実行して JSON を返す
#   ./db.sh apply path/to.sql      -- SQL ファイルをそのまま実行する
#
set -euo pipefail

PROJECT_REF="pliqeyrzhmoaehodoqjk"

token() {
  local raw
  raw=$(security find-generic-password -s "Supabase CLI" -a supabase -w 2>/dev/null) || {
    echo "keychain に Supabase のトークンがない。'npx supabase login' でログインする。" >&2
    exit 1
  }
  # supabase CLI は go-keyring 形式（base64）で保存している
  case "$raw" in
    go-keyring-base64:*) printf '%s' "${raw#go-keyring-base64:}" | base64 -d ;;
    *) printf '%s' "$raw" ;;
  esac
}

run_sql() {
  local sql="$1" body http status
  body=$(jq -Rn --arg q "$sql" '{query:$q}')
  http=$(curl -s -w '\n%{http_code}' -X POST \
    "https://api.supabase.com/v1/projects/${PROJECT_REF}/database/query" \
    -H "Authorization: Bearer $(token)" \
    -H "Content-Type: application/json" \
    -d "$body")
  status=$(printf '%s' "$http" | tail -n1)
  body=$(printf '%s' "$http" | sed '$d')
  if [ "$status" != "200" ] && [ "$status" != "201" ]; then
    echo "SQL 失敗 (HTTP $status): $body" >&2
    exit 1
  fi
  printf '%s\n' "$body"
}

case "${1:-}" in
  query)
    [ $# -ge 2 ] || { echo "usage: db.sh query \"<sql>\"" >&2; exit 1; }
    run_sql "$2"
    ;;
  apply)
    [ $# -ge 2 ] || { echo "usage: db.sh apply <file.sql>" >&2; exit 1; }
    [ -f "$2" ] || { echo "ファイルがない: $2" >&2; exit 1; }
    run_sql "$(cat "$2")"
    ;;
  *)
    echo "usage: db.sh {query \"<sql>\" | apply <file.sql>}" >&2
    exit 1
    ;;
esac
