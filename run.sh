#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
WORK="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$WORK/config.env"
mkdir -p "$WORK/out" "$WORK/backups" "$WORK/logs"
LOG="$WORK/logs/run.log"
STAMP="$(date +%Y%m%d_%H%M%S)"
log() { printf '%s [%s] %s\n' "$(date -Is)" "$1" "$2" >> "$LOG"; }
trap 'rc=$?; log ERROR "exit=$rc"; exit "$rc"' ERR

db_query() {
    "$CLIENT" --defaults-file="$AUTH" --batch --raw \
        --skip-column-names --execute="$1" --database="$DB"
}

dump_db() {
    "$DUMP" --defaults-file="$AUTH" --single-transaction \
        --default-character-set=utf8mb4 --result-file="$1" "$DB"
}

run_task() {
    test -r "$ERROR_LOG"
    if grep -Ei 'ERROR|CRASH' "$ERROR_LOG" > "$WORK/out/error-matches.txt"; then
        log WARN "Найдены совпадения; см. out/error-matches.txt"
    else
        rc=$?
        if (( rc == 1 )); then log INFO "Совпадений нет"; else return "$rc"; fi
    fi
}

log INFO "START db=$DB"
started_ms="$(date +%s%3N)"
run_task
finished_ms="$(date +%s%3N)"
log INFO "elapsed_ms=$((finished_ms - started_ms))"
log INFO "END result=OK"
exit 0
