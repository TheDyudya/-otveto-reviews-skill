# GraphQL-операции Ответо (анализ отзывов)

Эндпоинт `POST https://api.otveto.ru/graphql`. Заголовки — см. `auth.md`.
`MarketplaceType` (enum): `WB`, `OZON`, `YANDEX`, `AVITO`.

## Магазины
```graphql
query Stores {
  getWbStores { id: uuid name isObserved feedbackType }
  getOzonStores(input: {}) { id: uuid name }
}
```
`WbStoreResponse` также содержит: `activeToken, answerWithOutText, caption,
questionCaption, treatType, productNameInAnswer, reactToPhoto, delivery` и др.

## История анализов отзывов
```graphql
query AnalysesHistory($input: CommonGetAnalyticsHistory!) {
  getCommonFeedbacksAnalyticsHistoryV2(input: $input) {
    total
    items {
      id: uuid          # это analyticsId для запроса данных
      name typeName productId
      feedbackCount totalCount positiveCount negativeCount withAnswer maxReviewCount
      source createdAt  # createdAt — epoch ms
    }
  }
}
```
Input `CommonGetAnalyticsHistory`: обязательны `take: Int!`, `page: Int!`
(пагинация). Есть опциональные фильтры (магазин/маркетплейс/даты) — уточняйте
пробным запросом (см. ниже «Как узнать поля input»).

## Данные анализа (новый формат V3 — темы/плюсы/минусы)
```graphql
query AnalysisDataV3($input: CommonGetAnalyticsData!) {
  getCommonFeedbacksAnalyticsDataV3(input: $input) {
    productName feedbackRating feedbackCount positiveCount negativeCount withAnswer
    pluses { name }       # темы-плюсы (что хвалят)
    minuses { name }      # темы-минусы (на что жалуются)
    information { value }  # доп. наблюдения
  }
}
```
Input `CommonGetAnalyticsData`: обязательны `analyticsId: String!`,
`marketplace: MarketplaceType!`.

⚠️ Поля называются `pluses`/`minuses` (НЕ `plus`/`minus`).

## Данные анализа (старый формат — fallback)
Старые прогоны V3 не поддерживает: возвращает ошибку `"Аналитика старого
формата"`. Тогда берём обычный запрос с метриками:
```graphql
query AnalysisData($input: CommonGetAnalyticsData!) {
  getCommonFeedbacksAnalyticsData(input: $input) {
    productId productName storeId imageUrl
    feedbackRating feedbackCount positiveCount negativeCount withAnswer
    rewievsPerDay rewievsPerHundredSale maxReviewCount periodDate answer
  }
}
```
(Поля `rewievs...` — так в API, орфография их.) Скрипт `analysis-data.sh`
делает этот фолбэк автоматически.

## Лента отзывов с ответами (курсор)
```graphql
query Feedbacks($input: CommonGetFeedbacksAndAnswersCursor!) {
  getCommonFeedbacksAndAnswersCursor(input: $input) {
    items { ...CommonFeedbackAnswerType }
    pageInfo { hasNextPage endCursor }
  }
}
fragment CommonFeedbackAnswerType on CommonStoreFeedbackResponse {
  productId productName text date createdAt customerName storeName storeUuid
  productValuation imagesUrl feedbackId productImage
  pros cons isNew canAnswer canBePublished isArchived status source
  answerData { answer createdAt answerPublishedAt answerStatus rejectReasons }
  stopWords { inText inAnswer }
}
```
Input `CommonGetFeedbacksAndAnswersCursor`: обязателен `take: Int!`; пагинация
через `endCursor`. Опциональные фильтры (по данным клиента): `search`,
`withAnswer`, `sources`, `onlyNew`. Поле для фильтра по магазину —
НЕ `storeUuid`/`marketplaces` (отклоняются); точное имя уточняйте пробным
запросом. Realtime — подписка `subCommonFeedback` через `wss://ws.otveto.ru`.

## Операции записи (есть, но в скрипты НЕ вынесены)
- `CreateWbFeedbackAnalize` / `CreateOzonFeedbackAnalize` / `CreateWbFeedbackMassiveAnalize`
  — запустить новый анализ; затем `getCommonFeedbacksAnalyticsHistoryV2` покажет
  его, а `...DataV3` — результат.
- `CheckWbFeedbackAnalyzeDates` / `CheckOzonFeedbackAnalyzeDates` — доступные даты.
- `AnswerCommonFeedbacks`, `Archive...` и пр. — ответы/архив.
Добавляйте осознанно (это изменяющие операции).

## Как узнать поля незнакомого input
Отправьте операцию с пустым/частичным `input` — сервер вернёт `BAD_USER_INPUT`
со списком обязательных/неизвестных полей. Так выяснены `take`/`page`/
`analyticsId`/`marketplace` выше. Это безопасно (валидация, без записи).
