#!/usr/bin/env bash
# Список магазинов продавца (WB + Ozon): id (uuid) и название.
# id магазина нужен для фильтров и привязки анализов.
# Использование: scripts/stores.sh
set -euo pipefail
. "$(dirname "$0")/common.sh"

read -r -d '' Q <<'GQL' || true
query Stores {
  getWbStores { id: uuid name isObserved feedbackType }
  getOzonStores(input: {}) { id: uuid name }
}
GQL

run_op "$Q"
