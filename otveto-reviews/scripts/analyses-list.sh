#!/usr/bin/env bash
# История анализов отзывов (каждый элемент = один прогон анализа).
# items[].id — это analyticsId для analysis-data.sh.
# Использование: scripts/analyses-list.sh [page] [take]
#   page  — номер страницы (по умолчанию 1)
#   take  — сколько на страницу (по умолчанию 20)
set -euo pipefail
. "$(dirname "$0")/common.sh"

PAGE="${1:-1}"
TAKE="${2:-20}"

read -r -d '' Q <<'GQL' || true
query AnalysesHistory($input: CommonGetAnalyticsHistory!) {
  getCommonFeedbacksAnalyticsHistoryV2(input: $input) {
    total
    items {
      id: uuid
      name
      typeName
      productId
      feedbackCount
      totalCount
      positiveCount
      negativeCount
      withAnswer
      maxReviewCount
      source
      createdAt
    }
  }
}
GQL

VARS="$(printf '{"input":{"take":%d,"page":%d}}' "$TAKE" "$PAGE")"
run_op "$Q" "$VARS"
