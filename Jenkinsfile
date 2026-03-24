// Define globally so it can be shared across all stages
def dockerImage = ''

pipeline {
    agent any

    environment {
        REGISTRY = ""
        // Enforcing lowercase to prevent registry denied errors
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
                    docker.withRegistry("", 'docker-hub-credentials') {
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

        stage('Deploy to Kubernetes') {
            steps {
                // 'k8s-config-id' must match the 'ID' you gave the credential in Jenkins
                withCredentials([file(credentialsId: 'k8s-config-id', variable: 'KUBECONFIG_FILE')]) {
                    script {
                        // Use the variable $KUBECONFIG_FILE which points to the temp path
                        sh "kubectl --kubeconfig ${KUBECONFIG_FILE} rollout restart deployment community-web --v=9"
                        sh "kubectl --kubeconfig ${KUBECONFIG_FILE} rollout status deployment community-web"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully pushed ${IMAGE_NAME}:${IMAGE_TAG} to Kubernetes."
        }
        failure {
            echo "Pipeline failed. Check Factor 11: Logs in the Jenkins console output."
        }
    }
}
