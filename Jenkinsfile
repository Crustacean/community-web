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

        stage('Deploy to Kubernetes') {
	    steps {
		withCredentials([file(credentialsId: 'k8s-config-id', variable: 'KUBECONFIG_FILE')]) {
		    script {
		        // Using single quotes is more secure for secret variables
		        sh 'kubectl --kubeconfig $KUBECONFIG_FILE rollout restart deployment community-web'
		        sh 'kubectl --kubeconfig $KUBECONFIG_FILE rollout status deployment community-web'
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
