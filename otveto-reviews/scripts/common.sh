#!/usr/bin/env bash
# Общий помощник: загрузка токена и обёртка над GraphQL-эндпоинтом Ответо.
# Подключается каждым скриптом: . "$(dirname "$0")/common.sh"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Токен и URL — из config/.env (см. config/.env.example).
if [ -f "$SKILL_DIR/config/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$SKILL_DIR/config/.env"
  set +a
fi

: "${OTVETO_TOKEN:?Не задан OTVETO_TOKEN. Скопируйте config/.env.example в config/.env и впишите токен (значение заголовка authorization из app.otveto.ru).}"
OTVETO_GRAPHQL_URL="${OTVETO_GRAPHQL_URL:-https://api.otveto.ru/graphql}"

# gql '<JSON-тело {"query":...,"variables":...}>' → печатает сырой ответ (JSON).
gql() {
  curl -sS "$OTVETO_GRAPHQL_URL" \
    -H "authorization: $OTVETO_TOKEN" \
    -H "content-type: application/json" \
    -H "source: api" \
    --max-time 60 \
    --data "$1"
}

# Красивый вывод JSON из stdin (jq → python3 → как есть).
pretty() {
  if command -v jq >/dev/null 2>&1; then
    jq .
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import sys,json; print(json.dumps(json.load(sys.stdin), ensure_ascii=False, indent=2))' 2>/dev/null || cat
  else
    cat
  fi
}

# Собрать сырой ответ операции (без pretty): raw_op '<query>' '<variables-json>'.
# query и variables передаём в python через env — без проблем с кавычками/скобками.
raw_op() {
  local vars="${2:-}"
  [ -z "$vars" ] && vars='{}'
  local body
  body="$(GQL_QUERY="$1" GQL_VARS="$vars" python3 -c 'import os,json; print(json.dumps({"query":os.environ["GQL_QUERY"],"variables":json.loads(os.environ["GQL_VARS"])}))')"
  gql "$body"
}

# Выполнить операцию и красиво напечатать: run_op '<query>' '<variables-json>'.
run_op() {
  raw_op "$1" "${2:-}" | pretty
}
