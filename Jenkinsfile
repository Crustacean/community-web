def dockerImage = ''

pipeline {
    agent any

    environment {
        IMAGE_NAME = "em22435/community-watch-web".toLowerCase()
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
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
                sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
                sh "docker rmi ${IMAGE_NAME}:latest || true"
            }
        }

        stage('Deploy to Dev namespace') {
            steps {
                withKubeConfig(
                    caCertificate: '', 
                    clusterName: '', 
                    contextName: '', 
                    credentialsId: 'jenkins-serviceaccount-token', 
                    namespace: '', 
                    restrictKubeConfigAccess: false, 
                    serverUrl: 'https://192.168.49.2:8443'
                ) {
                    script {
                        sh "kubectl set image deployment/community-watch-web community-watch-web=${IMAGE_NAME}:${IMAGE_TAG} -n dev"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully deployed version ${IMAGE_TAG} to the cluster."
        }
        failure {
            echo "Pipeline failed. Review the console output for specific error details."
        }
    }
}