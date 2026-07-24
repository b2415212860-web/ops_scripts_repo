#!/bin/bash
# 数据库备份脚本
# 用法: ./backup_database.sh <db_name> [backup_dir]

set -euo pipefail

DB_NAME="${1:?错误: 请指定数据库名称}"
BACKUP_DIR="${2:-/data/backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql.gz"

# 检查备份目录
mkdir -p "${BACKUP_DIR}"

# 执行备份
echo "开始备份数据库: ${DB_NAME}"
if pg_dump "${DB_NAME}" | gzip > "${BACKUP_FILE}"; then
    echo "备份成功: ${BACKUP_FILE}"
    # 清理 7 天前的备份
    find "${BACKUP_DIR}" -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete
    echo "已清理 7 天前的旧备份"
    exit 0
else
    echo "错误: 数据库备份失败" >&2
    exit 1
fi