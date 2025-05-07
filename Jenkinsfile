pipeline {
    agent any
    
    parameters {
        choice(name: 'ACTION', choices: ['up', 'down'], description: 'Docker compose action to perform')
        booleanParam(name: 'DETACHED', defaultValue: true, description: 'Run containers in detached mode')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'production'], description: 'Deployment environment')
    }
    
    environment {
        ENV_FILE = '.env'
        DOCKER_COMPOSE_FILE = 'docker-compose.yaml'
        DOCKER_REGISTRY = credentials('docker-registry-url')
        DOCKER_CREDS = credentials('docker-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Set build version based on git commit
                    env.BUILD_VERSION = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.BUILD_TIMESTAMP = sh(script: 'date +%Y%m%d%H%M%S', returnStdout: true).trim()
                }
            }
        }
        
        stage('Create Environment Config') {
            steps {
                script {
                    // Create .env file from Jenkins credentials
                    // Use different credential IDs for different environments
                    def credentialsId = "env-file-${params.ENVIRONMENT}"
                    withCredentials([string(credentialsId: credentialsId, variable: 'ENV_CONTENT')]) {
                        writeFile file: env.ENV_FILE, text: ENV_CONTENT
                    }
                }
            }
        }
        
        stage('Validate Compose File') {
            steps {
                sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} config"
            }
        }
        
        stage('Docker Login') {
            when {
                expression { params.ACTION == 'up' }
            }
            steps {
                sh 'echo $DOCKER_CREDS_PSW | docker login $DOCKER_REGISTRY -u $DOCKER_CREDS_USR --password-stdin'
            }
        }
        
        stage('Pull Latest Images') {
            when {
                expression { params.ACTION == 'up' }
            }
            steps {
                sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} pull"
            }
        }
        
        stage('Apply Database Migrations') {
            when {
                expression { params.ACTION == 'up' }
            }
            steps {
                // Example: Run migrations before starting the services
                // Adjust as needed for your project
                sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} run --rm web python manage.py migrate"
            }
            post {
                failure {
                    slackSend(color: 'danger', message: "Migration failed for ${params.ENVIRONMENT} environment!")
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    def detachFlag = params.DETACHED ? '-d' : ''
                    
                    if (params.ACTION == 'up') {
                        // Deploy with health checks
                        sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} up ${detachFlag}"
                        
                        if (params.DETACHED) {
                            // Verify services started correctly
                            sh "sleep 10" // Give services time to start
                            sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} ps"
                            sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} logs --tail=100"
                        }
                    } else if (params.ACTION == 'down') {
                        // Graceful shutdown
                        sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} down"
                    }
                }
            }
            post {
                success {
                    script {
                        def action = params.ACTION == 'up' ? 'Deployment' : 'Shutdown'
                        slackSend(color: 'good', message: "${action} successful on ${params.ENVIRONMENT} environment!")
                    }
                }
                failure {
                    script {
                        def action = params.ACTION == 'up' ? 'Deployment' : 'Shutdown'
                        slackSend(color: 'danger', message: "${action} failed on ${params.ENVIRONMENT} environment!")
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up .env file to avoid leaving sensitive data
            sh "rm -f ${env.ENV_FILE}"
            sh "docker logout ${env.DOCKER_REGISTRY}"
            
            // Archive logs and artifacts
            archiveArtifacts artifacts: 'logs/**/*.log', allowEmptyArchive: true
            
            // Notify about pipeline completion
            slackSend(color: currentBuild.currentResult == 'SUCCESS' ? 'good' : 'danger',
                     message: "Pipeline ${currentBuild.currentResult}: ${env.JOB_NAME} #${env.BUILD_NUMBER}\nEnvironment: ${params.ENVIRONMENT}\nAction: ${params.ACTION}")
        }
    }
} 