# Gitee Actions Configuration
# Jenkins pipeline for Gitee

pipeline {
    agent any

    environment {
        FLUTTER_VERSION = '3.16.0'
        JAVA_VERSION = '17'
        NODE_VERSION = '18'
    }

    stages {
        stage('Setup') {
            steps {
                sh 'flutter doctor'
                sh 'flutter pub get'
                sh 'npm install'
            }
        }

        stage('Analyze') {
            steps {
                sh 'flutter analyze --fatal-infos --fatal-warnings'
                sh 'flutter test --coverage'
                sh 'flutter test integration_test'
            }
        }

        stage('Build Web') {
            steps {
                sh 'flutter build web --release --web-renderer canvaskit --pwa-strategy=offline-first'
                sh 'npm run build:web'
            }
        }

        stage('Build Mobile') {
            parallel {
                stage('Build Android') {
                    steps {
                        sh 'flutter build apk --release --split-per-abi'
                        sh 'flutter build appbundle --release'
                    }
                }
                stage('Build iOS') {
                    steps {
                        sh 'flutter build ios --release --no-codesign'
                    }
                }
            }
        }

        stage('Build Desktop') {
            parallel {
                stage('Build Linux') {
                    steps {
                        sh 'flutter build linux --release'
                    }
                }
                stage('Build Windows') {
                    steps {
                        sh 'flutter build windows --release'
                    }
                }
                stage('Build macOS') {
                    steps {
                        sh 'flutter build macos --release'
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'echo "Deploy to Gitee Pages"'
                sh 'echo "Deploy to app stores"'
            }
        }
    }

    post {
        success {
            discordSend description: "Build successful", footer: "Katya AI REChain Mesh", link: env.BUILD_URL, result: currentBuild.currentResult, title: "Build #${env.BUILD_NUMBER}", webhookURL: "${env.DISCORD_WEBHOOK}"
        }
        failure {
            discordSend description: "Build failed", footer: "Katya AI REChain Mesh", link: env.BUILD_URL, result: currentBuild.currentResult, title: "Build #${env.BUILD_NUMBER}", webhookURL: "${env.DISCORD_WEBHOOK}"
        }
        always {
            cleanWs()
        }
    }
}
