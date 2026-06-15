#!/usr/bin/env bash
# Лента отзывов с ответами (курсорная пагинация).
# Возвращает товар, оценку, плюсы/минусы покупателя, текст, дату и ответ.
# Использование: scripts/feedbacks.sh [take] [endCursor]
#   take      — сколько отзывов (по умолчанию 20)
#   endCursor — курсор следующей страницы (из pageInfo.endCursor пред. вызова)
set -euo pipefail
. "$(dirname "$0")/common.sh"

TAKE="${1:-20}"
CURSOR="${2:-}"

read -r -d '' Q <<'GQL' || true
query Feedbacks($input: CommonGetFeedbacksAndAnswersCursor!) {
  getCommonFeedbacksAndAnswersCursor(input: $input) {
    items {
      productName
      productValuation
      pros
      cons
      text
      date
      customerName
      storeName
      answerData { answer answerStatus answerPublishedAt }
      isArchived
      canAnswer
    }
    pageInfo { hasNextPage endCursor }
  }
}
GQL

if [ -n "$CURSOR" ]; then
  VARS="$(printf '{"input":{"take":%d,"endCursor":"%s"}}' "$TAKE" "$CURSOR")"
else
  VARS="$(printf '{"input":{"take":%d}}' "$TAKE")"
fi

run_op "$Q" "$VARS"
