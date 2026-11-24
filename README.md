# ПМ.07 — учебная практика, вариант 17 «Ремонт компьютерной техники»

**Маршрут:** MariaDB 10 · Linux, Ubuntu Server 22.04
**СУБД:** MariaDB 10.6
**Исходная база:** `pm07_v17`, проверочная: `pm07_v17_restore`
**Предметные таблицы:** `devices`, `requests`, `parts`
**Операция:** проверка журнала ошибок на ключевые слова `ERROR` и `CRASH`

## Файлы

| Файл | Назначение |
| --- | --- |
| `input.sql` | исходные данные варианта 17 (четыре таблицы, по 4 строки) |
| `grants.sql` | базы, учётные записи `admin`, `app_user`, `readonly` и права (пароли-заглушки) |
| `run.sh` | скрипт операции: поиск `ERROR`/`CRASH` в журнале, результат в `out/error-matches.txt` |
| `config.example.env` | пример конфигурации, копируется в `config.env` |
| `logs/run.log` | журнал фактических запусков (ручных и по расписанию) |
| `out/error-matches.txt` | результат последней операции |
| `rows-before.txt`, `rows-after.txt` | контрольные значения до и после восстановления |
| `sha256-manual.txt` | SHA-256 ручной копии `manual.sql` |

## Подготовка

1. Скопировать пример конфигурации:

       cp config.example.env config.env

2. Создать профиль подключения `auth/client.cnf` (в репозиторий не входит):

       mkdir -p auth
       printf '[client]\nuser=admin\npassword=ВАШ_ПАРОЛЬ\nhost=127.0.0.1\nport=3306\n' > auth/client.cnf
       chmod 600 auth/client.cnf

3. Загрузить исходные данные под `admin`:

       mariadb --defaults-file=auth/client.cnf pm07_v17 < input.sql

## Запуск

    cd ~/pm07
    bash ./run.sh; echo $?

Ожидаемый результат: код `0`, в `logs/run.log` строки `START`, `WARN «Найдены совпадения…»`
и `END result=OK`, в `out/error-matches.txt` — найденные строки журнала.
Если файл журнала недоступен, скрипт завершается ненулевым кодом и пишет `ERROR exit=1`.

Дополнение: между `START` и `END` пишется `elapsed_ms=…` — длительность операции в миллисекундах.

## Расписание

Запуск от того же пользователя Linux, что и ручная проверка:

    0 3 * * * /bin/bash "$HOME/pm07/run.sh" >> "$HOME/pm07/logs/cron.log" 2>&1

Периодичность ежедневная: журнал ошибок достаточно проверять раз в сутки.

## Проверка прав

    mariadb -h 127.0.0.1 -u readonly -p pm07_v17 -e "select * from access_probe;"
    mariadb -h 127.0.0.1 -u readonly -p pm07_v17 -e "delete from access_probe where id=1;"

Вторая команда должна вернуть `ERROR 1142 (42000): DELETE command denied …`,
то есть отказ по причине отсутствия привилегии, а не ошибка входа.

## Безопасность

Пароли хранятся только в `auth/client.cnf` (права 600). Профиль, дамп `manual.sql`
и каталог `backups/` исключены через `.gitignore` и в репозиторий не передаются.
