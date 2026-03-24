// Define globally to share the docker image object across stages 
def dockerImage = ''

pipeline {
    agent any

    environment {
        // Enforcing lowercase to prevent Docker Hub registry rejection [cite: 10]
        IMAGE_NAME = "em22435/community-watch-web".toLowerCase()
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulls the source code from the configured SCM [cite: 9]
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Builds the image and assigns it to the global variable [cite: 10]
                    dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Authenticates and pushes both the build tag and 'latest' [cite: 11]
                    docker.withRegistry("", 'docker-hub-credentials') {
                        dockerImage.push()
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                // Removes local images to save disk space on the Jenkins agent
                sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
                sh "docker rmi ${IMAGE_NAME}:latest || true"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Securely binds the Kubeconfig file to a temporary environment variable 
                withCredentials([file(credentialsId: 'k8s-config-id', variable: 'KUBECONFIG_FILE')]) {
                    script {
                        // Triggers a rolling update using the provided credential [cite: 14]
                        sh 'kubectl --kubeconfig ${KUBECONFIG_FILE} rollout restart deployment community-web'
                        
                        // Monitors the rollout progress in the Jenkins console
                        sh 'kubectl --kubeconfig ${KUBECONFIG_FILE} rollout status deployment community-web'
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully deployed version ${IMAGE_TAG} to the cluster. [cite: 16]"
        }
        failure {
            echo "Pipeline failed. Review the console output for specific error details. [cite: 17]"
        }
    }
}
