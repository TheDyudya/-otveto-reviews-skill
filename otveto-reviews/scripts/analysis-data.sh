#!/usr/bin/env bash
# Детальные данные одного анализа отзывов по analyticsId.
# Сначала пробуем новый формат V3 (плюсы/минусы/темы), при «Аналитике старого
# формата» — откатываемся на обычный getCommonFeedbacksAnalyticsData (метрики).
# Использование: scripts/analysis-data.sh <analyticsId> [marketplace]
#   marketplace — WB | OZON | YANDEX | AVITO (по умолчанию WB)
set -euo pipefail
. "$(dirname "$0")/common.sh"

AID="${1:?Укажите analyticsId (см. scripts/analyses-list.sh → items[].id)}"
MP="$(printf '%s' "${2:-WB}" | tr '[:lower:]' '[:upper:]')"
VARS="$(printf '{"input":{"analyticsId":"%s","marketplace":"%s"}}' "$AID" "$MP")"

read -r -d '' Q_V3 <<'GQL' || true
query AnalysisDataV3($input: CommonGetAnalyticsData!) {
  getCommonFeedbacksAnalyticsDataV3(input: $input) {
    productName
    feedbackRating
    feedbackCount
    positiveCount
    negativeCount
    withAnswer
    pluses { name }
    minuses { name }
    information { value }
  }
}
GQL

read -r -d '' Q_V1 <<'GQL' || true
query AnalysisData($input: CommonGetAnalyticsData!) {
  getCommonFeedbacksAnalyticsData(input: $input) {
    productId
    productName
    storeId
    imageUrl
    feedbackRating
    feedbackCount
    positiveCount
    negativeCount
    withAnswer
    rewievsPerDay
    rewievsPerHundredSale
    maxReviewCount
    periodDate
    answer
  }
}
GQL

RESP="$(raw_op "$Q_V3" "$VARS")"
if echo "$RESP" | grep -q "старого формата" || echo "$RESP" | grep -q "GRAPHQL_VALIDATION_FAILED"; then
  # Старый формат / V3 недоступен — запрашиваем обычные метрики.
  raw_op "$Q_V1" "$VARS" | pretty
else
  echo "$RESP" | pretty
fi
