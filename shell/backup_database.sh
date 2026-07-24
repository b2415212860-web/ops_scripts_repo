#!/bin/bash
# 数据库备份脚本
# 用法: ./backup_database.sh <db_name> [backup_dir]

# 备份函数：被 source 时只定义不执行，便于单元测试
backup_database() {
    local db_name="${1:?错误: 请指定数据库名称}"
    local backup_dir="${2:-/data/backups}"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${backup_dir}/${db_name}_${timestamp}.sql.gz"

    # 检查备份目录
    mkdir -p "${backup_dir}"

    # 执行备份
    echo "开始备份数据库: ${db_name}"
    if pg_dump "${db_name}" | gzip > "${backup_file}"; then
        echo "备份成功: ${backup_file}"
        # 清理 7 天前的备份
        find "${backup_dir}" -name "${db_name}_*.sql.gz" -mtime +7 -delete
        echo "已清理 7 天前的旧备份"
        return 0
    else
        echo "错误: 数据库备份失败" >&2
        return 1
    fi
}

# 仅直接执行时调用函数，被 source 时跳过（set 也移入此处避免污染调用方）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    backup_database "$@"
fi