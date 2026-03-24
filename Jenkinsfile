pipeline {
    agent any

    environment {
        REGISTRY = ""
        IMAGE_NAME = "em22435/community-watch-web".toLowerCase()
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

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Ensure 'docker-hub-credentials' matches the ID in Jenkins Credentials
                    docker.withRegistry("", 'docker-hub-credentials') { 
                        dockerImage.push() [cite: 5]
                        dockerImage.push("latest") [cite: 6]
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
