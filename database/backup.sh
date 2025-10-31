#!/bin/sh
PATH=/usr/bin:/bin

# CONFIG
MYSQL_USER=${MYSQL_USER:-bkp}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-RpyCr8ALmNXeYWVRhUSfqMh7}
MYSQL_DATABASE=${MYSQL_DATABASE:-site_cead}
CONTAINER_NAME=site-cead-db

BACKUP_ROOT="/media/truenas/backups/site-cead-database"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d)"
BACKUP_FILE="$BACKUP_DIR/${MYSQL_DATABASE}-$(date +%H).sql.gz"
LOG_FILE="$BACKUP_ROOT/backup-$(date +%Y%m%d).log"
RETENTION_DAYS=45

mkdir -p "$BACKUP_DIR"

# Verifica se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[Backup] $(date +'%F %T') Container $CONTAINER_NAME não está em execução." >> "$LOG_FILE"
    exit 1
fi

echo "[Backup] $(date +'%F %T') Iniciando backup: $BACKUP_FILE" >> "$LOG_FILE"

# Executa o dump dentro do container e comprime
docker exec "$CONTAINER_NAME" \
    mysqldump \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        --databases "$MYSQL_DATABASE" \
        --no-tablespaces \
    | gzip > "$BACKUP_FILE"

# Log do tamanho do arquivo
BACKUP_SIZE_BYTES=$(stat -c %s "$BACKUP_FILE" 2>/dev/null)
BACKUP_SIZE_MB=$(awk "BEGIN {mb=$BACKUP_SIZE_BYTES/1048576; printf \"%.2f\", mb}" | sed 's/\./,/')
echo "[Backup] $(date +'%F %T') Backup finalizado (${BACKUP_SIZE_MB}MB)." >> "$LOG_FILE"

# Limpeza de backups antigos
echo "[Backup] $(date +'%F %T') Apagando backups com mais de $RETENTION_DAYS dias..." >> "$LOG_FILE"
find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;
find "$BACKUP_ROOT" -maxdepth 1 -name "backup-*.log" -mtime +$RETENTION_DAYS -delete
