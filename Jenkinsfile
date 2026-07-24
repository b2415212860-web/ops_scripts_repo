pipeline {
    agent none   // 不在 Master 上执行，由各 stage 指定 Agent

    environment {
        SHELLCHECK_OPTS = '-x -e SC1091'
    }

    stages {
        // Stage 1: 拉取代码
        stage('拉取代码') {
            agent { label 'master' }
            steps {
                checkout scm
                echo "代码拉取成功，当前分支: ${env.GIT_BRANCH}"
            }
        }

        // Stage 2: ShellCheck 静态分析
        stage('ShellCheck 静态检查') {
            agent { label 'shell-agent' }
            steps {
                script {
                    def shellFiles = sh(
                        script: 'find . -name "*.sh" -type f',
                        returnStdout: true
                    ).trim()
                    if (shellFiles) {
                        sh "find . -name '*.sh' -type f -print0 | xargs -0 shellcheck ${SHELLCHECK_OPTS}"
                    } else {
                        echo "未发现 .sh 文件，跳过 ShellCheck"
                    }
                }
            }
        }

        // Stage 3: Bats 单元测试
        stage('Bats 单元测试') {
            agent { label 'shell-agent' }
            steps {
                script {
                    def batsFiles = sh(
                        script: 'find . -name "*.bats" -type f 2>/dev/null || echo ""',
                        returnStdout: true
                    ).trim()
                    if (batsFiles) {
                        sh "find . -name '*.bats' -type f -print0 | xargs -0 bats --tap"
                    } else {
                        echo "未发现 .bats 测试文件，跳过测试"
                    }
                }
            }
        }

        // Stage 4: 语法检查
        stage('Shell 语法检查') {
            agent { label 'shell-agent' }
            steps {
                sh """
                    for f in \$(find . -name '*.sh' -type f); do
                        bash -n "\$f" && echo "✓ \$f OK" || echo "✗ \$f FAIL"
                    done
                """
            }
        }
    }

    post {
        success {
            echo '所有检查通过！'
        }
        failure {
            echo '检查未通过，请修复错误后重新提交'
        }
        always {
            cleanWs()
        }
    }
}