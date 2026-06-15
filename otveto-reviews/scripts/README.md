# scripts

| Скрипт | Что делает | Использование |
|---|---|---|
| `common.sh` | Общий помощник: грузит `config/.env`, обёртка `gql`/`run_op` | подключается остальными |
| `stores.sh` | Магазины продавца (WB+Ozon): id+название | `./scripts/stores.sh` |
| `analyses-list.sh` | История анализов (items[].id = analyticsId) | `./scripts/analyses-list.sh [page] [take]` |
| `analysis-data.sh` | Детали анализа: рейтинг, +/−, темы | `./scripts/analysis-data.sh <analyticsId> [WB\|OZON\|YANDEX\|AVITO]` |
| `feedbacks.sh` | Лента отзывов с ответами (курсор) | `./scripts/feedbacks.sh [take] [endCursor]` |

Вывод — JSON (с `jq` красиво, иначе python3). Перед запуском задайте токен в
`config/.env` (см. `config/.env.example`).

Пример:
```bash
./scripts/analyses-list.sh 1 20
./scripts/analysis-data.sh 80dfc4d9-61ff-4f82-86d7-342ef7bdd46f WB
```
