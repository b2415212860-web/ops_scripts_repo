#!/usr/bin/env bats
# shell/tests/test_backup_database.bats

setup() {
    # 测试前准备：创建临时目录和 mock
    export TEST_DIR=$(mktemp -d)
    export BACKUP_DIR="${TEST_DIR}/backups"
    # mock pg_dump 命令
    mkdir -p "${TEST_DIR}/bin"
    cat > "${TEST_DIR}/bin/pg_dump" <<'EOF'
#!/bin/bash
echo "CREATE TABLE test (id INT);"
EOF
    chmod +x "${TEST_DIR}/bin/pg_dump"
    export PATH="${TEST_DIR}/bin:$PATH"
    # 加载被测脚本中的函数（函数模式下 source 只定义不执行）
    source shell/backup_database.sh 2>/dev/null || true
}

teardown() {
    rm -rf "${TEST_DIR}"
}

@test "备份目录不存在时自动创建" {
    run bash -c "BACKUP_DIR='${BACKUP_DIR}' bash shell/backup_database.sh testdb '${BACKUP_DIR}'"
    [ -d "${BACKUP_DIR}" ]
}

@test "备份文件正确生成" {
    run bash shell/backup_database.sh testdb "${BACKUP_DIR}"
    [ "$status" -eq 0 ]
    ls "${BACKUP_DIR}"/testdb_*.sql.gz | wc -l | grep -q "^1$"
}

@test "未指定数据库名称时返回错误" {
    run bash shell/backup_database.sh
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "请指定数据库名称"
}

@test "备份文件是 gzip 格式" {
    run bash shell/backup_database.sh testdb "${BACKUP_DIR}"
    BACKUP_FILE=$(ls "${BACKUP_DIR}"/testdb_*.sql.gz | head -1)
    file "${BACKUP_FILE}" | grep -q "gzip"
}