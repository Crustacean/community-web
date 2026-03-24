pipeline {
    agent any

    environment {
        // The registry for GitHub
        REGISTRY = "ghcr.io"
        // Replace with your GitHub username and repo name in lowercase
        IMAGE_NAME = "ghcr.io/em22435/community-watch-web"
        // Use the build number as a unique tag
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Factor 1: One codebase tracked in revision control
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Factor 5: Build stage (creating the immutable artifact)
                    dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

	stage('Test Connection') {
            // Using the credentialsId you created in Jenkins
            withCredentials([usernamePassword(credentialsId: 'github-token-id', 
                             passwordVariable: 'GH_TOKEN', 
                             usernameVariable: 'GH_USER')]) {
                
                // Try a manual login to see the raw error message
                sh "echo ${GH_TOKEN} | docker login ghcr.io -u ${GH_USER} --password-stdin"
            }

        stage('Push to GHCR') {
            steps {
                script {
                    // Factor 3: Config (using credentials stored in Jenkins)
                    docker.withRegistry("https://${REGISTRY}", 'github-token-id') {
                        // Factor 5: Release stage (pushing to the registry)
                        dockerImage.push()
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                // Remove local images to save disk space on the Jenkins agent
                sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker rmi ${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        success {
            echo "Successfully pushed ${IMAGE_NAME}:${IMAGE_TAG} to GitHub Container Registry."
        }
        failure {
            echo "Pipeline failed. Check Factor 11: Logs in the Jenkins console output."
        }
    }
}
