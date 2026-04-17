#!/bin/sh
set -eu
PATH=/usr/bin:/bin

ENV_FILE="/srv/site-docker/.env"

if [ -f "$ENV_FILE" ]; then
    set -a
    . "$ENV_FILE"
    set +a
else
    echo "[Backup] $(date +'%F %T') Arquivo .env não encontrado: $ENV_FILE" >&2
    exit 1
fi

MYSQL_BKP_USER=${MYSQL_BKP_USER:-bkp}
MYSQL_BKP_PASSWORD=${MYSQL_BKP_PASSWORD:?MYSQL_BKP_PASSWORD não definido}
MYSQL_DATABASE=${MYSQL_DATABASE:-site_cead}
CONTAINER_NAME=${CONTAINER_NAME:-site-cead-db}
BACKUP_ROOT="/media/truenas/backups/site-cead-database"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d)"
BACKUP_FILE="$BACKUP_DIR/${MYSQL_DATABASE}-$(date +%H).sql.gz"
LOG_FILE="$BACKUP_ROOT/backup-$(date +%Y%m%d).log"
RETENTION_DAYS=120

mkdir -p "$BACKUP_ROOT" "$BACKUP_DIR"

log() {
    echo "[Backup] $(date +'%F %T') $1" >> "$LOG_FILE"
}

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log "Container $CONTAINER_NAME não está em execução."
    exit 1
fi

log "Iniciando backup: $BACKUP_FILE"

if docker exec "$CONTAINER_NAME" \
    mariadb-dump \
        --user="$MYSQL_BKP_USER" \
        --password="$MYSQL_BKP_PASSWORD" \
        --databases "$MYSQL_DATABASE" \
        --no-tablespaces \
    | gzip -f > "$BACKUP_FILE"; then
    :
else
    rm -f "$BACKUP_FILE"
    log "Erro ao gerar backup."
    exit 1
fi

if [ ! -s "$BACKUP_FILE" ]; then
    rm -f "$BACKUP_FILE"
    log "Backup inválido: arquivo não foi criado corretamente ou ficou vazio."
    exit 1
fi

BACKUP_SIZE_BYTES=$(stat -c %s "$BACKUP_FILE" 2>/dev/null || echo 0)
BACKUP_SIZE_MB=$(awk "BEGIN {mb=$BACKUP_SIZE_BYTES/1048576; printf \"%.2f\", mb}" | sed 's/\./,/')
log "Backup finalizado (${BACKUP_SIZE_MB}MB)."

log "Apagando backups com mais de $RETENTION_DAYS dias..."
find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" -exec rm -rf {} \;
find "$BACKUP_ROOT" -maxdepth 1 -name "backup-*.log" -mtime +"$RETENTION_DAYS" -delete
