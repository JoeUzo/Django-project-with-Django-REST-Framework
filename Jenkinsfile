pipeline {
  agent any

  parameters {
    booleanParam(name: 'RUN_SCAN',        defaultValue: true,  description: 'Run security scan')
    booleanParam(name: 'DETACHED',        defaultValue: true,  description: 'Run containers detached')
    booleanParam(name: 'RUN_MIGRATIONS',  defaultValue: true,  description: 'Run DB migrations after deploy')
  }

  environment {
    DOCKER_REGISTRY   = 'docker.io/joeuzo'
    IMAGE_NAME        = 'api-worker'
    DOCKER_CRED_ID    = 'docker-credentials'
  }

  options {
    ansiColor('xterm')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30'))
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.GIT_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        }
      }
    }

    stage('Build Image') {
      steps {
        script {
          env.IMAGE_TAG = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${GIT_TAG}"
          sh "docker build -t ${IMAGE_TAG} ."
        }
      }
    }

    stage('Security Scan') {
      when { expression { params.RUN_SCAN } }
      steps {
        sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${IMAGE_TAG} || true"
      }
    }

    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: DOCKER_CRED_ID,
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh 'echo $DOCKER_PASS | docker login $DOCKER_REGISTRY -u $DOCKER_USER --password-stdin'
          sh "docker push ${IMAGE_TAG}"
        }
      }
    }

    stage('Deploy with Docker Compose') {
      steps {
        script {
          def detachFlag = params.DETACHED ? '-d' : ''
          // Pull latest image then bring up services
          sh "docker-compose pull"
          sh "docker-compose up --build ${detachFlag}"
        }
      }
    }

    stage('Post-Deploy Migrations') {
      when { expression { params.RUN_MIGRATIONS } }
      steps {
        sh "docker-compose run --rm web python manage.py migrate"
      }
    }
  }

  post {
    always { cleanWs() }
    success { echo "✅ Pipeline Succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}" }
    failure { echo "❌ Pipeline Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}" }
  }
}
