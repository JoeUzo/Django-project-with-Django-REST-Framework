pipeline {
  agent any

  parameters {
    booleanParam(name: 'RUN_SCAN',       defaultValue: true, description: 'Run security scan')
    booleanParam(name: 'DETACHED',       defaultValue: true, description: 'Run containers in detached mode')
    booleanParam(name: 'RUN_MIGRATIONS', defaultValue: true, description: 'Run DB migrations after deploy')
  }

  environment {
    DOCKER_REGISTRY = 'docker.io/joeuzo'
    IMAGE_NAME      = 'api-worker'
    DOCKER_CRED_ID  = 'docker-credentials'
  }

  options {
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
          sh "echo $IMAGE_TAG"
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
        //   sh 'echo $DOCKER_PASS | docker login $DOCKER_REGISTRY -u $DOCKER_USER --password-stdin'
        //   sh "docker push ${IMAGE_TAG}"  
        // docker push docker.io/joeuzo/api-worker:${GIT_TAG}
          sh '''
           echo "$DOCKER_PASS" | docker login docker.io -u "$DOCKER_USER" --password-stdin
           docker push $IMAGE_TAG
           echo $IMAGE_TAG
           echo docker.io/joeuzo/api-worker:${GIT_TAG}
          '''
        }
      }
    }

    stage('Manual Approval') {
      steps {
        timeout(time: 30, unit: 'MINUTES') {
          input message: 'Approve deployment to DEV?', ok: 'Deploy' 
        }
      }
    }

    stage('Prepare Env File') {
      steps {
        withCredentials([file(credentialsId: 'api-worker-env-file', variable: 'ENV_FILE')]) {
          sh 'cp $ENV_FILE .env'
        }
      }
    }

    stage('Deploy with Docker Compose') {
      steps {
        script {
          def detachFlag = params.DETACHED ? '-d' : ''
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


   stage('API Smoke Test') {
      steps {
        script {
          def HOST_IP = sh(script: '''hostname -I | awk '{print $1}' ''', returnStdout: true).trim()
          sh "curl -f -X POST http://${HOST_IP}:8000/api/process/ -H 'Content-Type: application/json' -d '{\"email\":\"you@example.com\",\"message\":\"Hello\"}'"
        }
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline Succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    }
    failure {
      echo "❌ Pipeline Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    }
    
    always {
      cleanWs()

       // Send email notification
      emailext (
          subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
          body: """Build Status: ${currentBuild.currentResult}
          Build URL: ${env.BUILD_URL}
          Build Number: ${env.BUILD_NUMBER}
          Action: ${params.ACTION}
          Cluster: ${params.CLUSTER_NAME}
          Region: ${params.AWS_REGION}""",
          recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']]
      )
    }
  }
}
