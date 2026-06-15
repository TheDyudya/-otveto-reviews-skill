# otveto-reviews-skill

Claude Code skill для анализа отзывов маркетплейсов (Wildberries / Ozon) через
API Ответо (app.otveto.ru).

Скилл достаёт данные раздела «Анализ отзывов»: магазины продавца, прогоны
анализа отзывов и их результаты (рейтинг, кол-во, позитив/негатив, темы —
плюсы/минусы), ленту отзывов с ответами.

## Структура
```
otveto-reviews/
├── SKILL.md                 # как агенту пользоваться (читается Claude)
├── config/
│   ├── .env.example         # шаблон; скопировать в .env и вписать токен
│   └── README.md
├── references/
│   ├── auth.md              # эндпоинт, заголовки, как достать токен
│   └── operations.md        # GraphQL-операции и поля (справочник API)
└── scripts/
    ├── common.sh            # загрузка токена + gql-обёртка
    ├── stores.sh            # магазины продавца
    ├── analyses-list.sh     # история анализов отзывов
    ├── analysis-data.sh     # детали анализа (рейтинг, плюсы/минусы, темы)
    ├── feedbacks.sh         # лента отзывов с ответами
    └── README.md
```

## Установка
```bash
# как локальный скилл текущего пользователя:
cp -r otveto-reviews ~/.claude/skills/otveto-reviews
cd ~/.claude/skills/otveto-reviews
cp config/.env.example config/.env   # вписать OTVETO_TOKEN
```
Токен — значение заголовка `authorization` из app.otveto.ru (см.
`otveto-reviews/references/auth.md`). `config/.env` в `.gitignore` —
в репозиторий не попадёт.

## Использование
Спросите Claude: «разбери отзывы по моему магазину / товару X». Скилл сам
дёрнет нужные операции. Или вручную:
```bash
otveto-reviews/scripts/stores.sh
otveto-reviews/scripts/analyses-list.sh 1 20
otveto-reviews/scripts/analysis-data.sh <analyticsId> WB
```

## Безопасность
Токен даёт доступ к аккаунту продавца Ответо. Не коммитьте `config/.env`.
При утечке — перелогиньтесь в app.otveto.ru (токен сменится).
