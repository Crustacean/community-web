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
		        sh 'kubectl config --kubeconfig=$KUBECONFIG_FILE set-context --current --user=jenkins-service-account'
		        sh 'kubectl rollout restart deployment community-web --namespace=dev --kubeconfig=$KUBECONFIG_FILE'
		        sh 'kubectl rollout status deployment community-web --namespace=dev --kubeconfig=$KUBECONFIG_FILE'
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
