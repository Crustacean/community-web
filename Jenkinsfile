pipeline {
    agent any

    environment {
        REGISTRY = "ghcr.io"
        IMAGE_NAME = "ghcr.io/em22435/community-watch-web"
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

        stage('Test Connection') {
            steps { // Added missing steps block
                script { // Added script block for withCredentials
                    withCredentials([usernamePassword(credentialsId: 'github-token-id', 
                                     passwordVariable: 'GH_TOKEN', 
                                     usernameVariable: 'GH_USER')]) {
                        sh "echo ${GH_TOKEN} | docker login ghcr.io -u ${GH_USER} --password-stdin"
                    }
                } // Closed script
            } // Closed steps
        } // Closed stage

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
