pipeline {
    agent any

    environment {
        REGISTRY = ""
        // Ensure this matches your actual Docker Hub username
        IMAGE_NAME = "em22435/community-watch-web".toLowerCase() [cite: 3]
        IMAGE_TAG = "${env.BUILD_NUMBER}" [cite: 3]
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm [cite: 3]
            }
        }

        stage('Build Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}") [cite: 4]
                }
            }
        }

        stage('Push to Docker Hub') {
            steps { // Added missing steps block
                script {
                    // Uses the ID 'docker-hub-credentials' from your Jenkins Credential Store
                    docker.withRegistry("", 'docker-hub-credentials') { [cite: 5]
                        dockerImage.push() [cite: 5]
                        dockerImage.push("latest") [cite: 6]
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                // Factor 9: Disposability - Cleaning up local images after push
                sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}" [cite: 7]
                sh "docker rmi ${IMAGE_NAME}:latest" [cite: 7]
            }
        }
    }

    post {
        success {
            echo "Successfully pushed ${IMAGE_NAME}:${IMAGE_TAG} to Docker Hub." [cite: 8, 9]
        }
        failure {
            echo "Pipeline failed. Check Factor 11: Logs in the Jenkins console output." [cite: 10]
        }
    }
}
