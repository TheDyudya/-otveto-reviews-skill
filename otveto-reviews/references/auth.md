# Авторизация и эндпоинт

- **Эндпоинт:** `POST https://api.otveto.ru/graphql`
- **Подписки (realtime):** `wss://ws.otveto.ru` (в скилле не используются)
- **Заголовки запроса:**
  - `authorization: <OTVETO_TOKEN>` — токен аккаунта продавца (без префикса
    `Bearer`, просто значение).
  - `content-type: application/json`
  - `source: api` (клиент шлёт `source`; ставим `api`)

## Где взять токен
app.otveto.ru хранит токен в состоянии авторизации и шлёт его заголовком
`authorization` на каждый запрос к `/graphql`. Достать:

1. Войти на https://app.otveto.ru
2. DevTools (F12) → Network → открыть «Анализ отзывов»
3. Любой запрос на `/graphql` → Request Headers → значение `authorization`

Токен привязан к аккаунту (даёт доступ к его магазинам и отзывам). Хранить как
секрет, при утечке — перевыпустить (перелогиниться в app.otveto.ru).

## Проверка токена
```bash
curl -sS https://api.otveto.ru/graphql \
  -H "authorization: $OTVETO_TOKEN" -H "content-type: application/json" -H "source: api" \
  --data '{"query":"query{ user{ __typename } getWbStores{ __typename } }"}'
```
Ответ с `data` (а не `errors`/UNAUTHENTICATED) = токен валиден.
