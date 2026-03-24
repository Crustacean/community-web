pipeline {
    agent any

    environment {
        REGISTRY = "ghcr.io"
        IMAGE_NAME = "ghcr.io/em22435/community-watch-web".toLowerCase()
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to GHCR') {
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}", 'github-token-id') {
                        dockerImage.push()
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker rmi ${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        success {
            echo "Successfully pushed ${IMAGE_NAME}:${IMAGE_TAG} to GHCR."
        }
        failure {
            echo "Pipeline failed. Check Factor 11: Logs in the Jenkins console output."
        }
    }
}
