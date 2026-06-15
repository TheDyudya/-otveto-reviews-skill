# config

Настройки скилла. Реальный токен кладётся в `.env` (в `.gitignore`,
в репозиторий не коммитится).

```bash
cp config/.env.example config/.env
# открыть config/.env и вписать OTVETO_TOKEN
```

`OTVETO_TOKEN` — значение HTTP-заголовка `authorization`, которым app.otveto.ru
ходит в `https://api.otveto.ru/graphql`. Как достать — см. комментарий в
`.env.example` и `../references/auth.md`.
