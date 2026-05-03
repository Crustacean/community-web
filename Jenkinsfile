def dockerImage = ''

pipeline {
    agent any

    environment {
        IMAGE_NAME = "em22435/community-watch-web".toLowerCase()
        IMAGE_TAG  = "${env.BUILD_NUMBER}"

        KUBE_CA_CERT = '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
a3ViZUNBMB4XDTI2MDQyNDExNDkwOVoXDTM2MDQyMjExNDkwOVowFTETMBEGA1UE
AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJno
8eiJ0FZapXZ40Fs5Oy2t9Y6hSwLQBFAHvuU3DiMeTBeL2iKYeKbnHYmaeD4IzzPK
otHoOzN//UugSWl6Jg8lcvhhULBiZ/u70TEVpY0QCmoV2NdPYYWAAxHMSGPvNQIj
WA05vWum4ge1iUKf34edrReu43mr0rD1lKVFpGy5zYdNqm9GCyM6kerbdO5ha/u5
LNMR/jDTk9OArnjlxoEtNm1i30vd4zbet8X9atQcjWELLDzFBQoKa5yVwTjf0UzD
ulABms3/ODeyKOMxSVaymzVOsqooHPrXfag8WBfx45kA3AvsrfxVdgyKiML2j39V
YGTZVPBveNOG5GzyaYkCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
BBTUhbcJY6pJxshLV7U1niJOsQbj2zANBgkqhkiG9w0BAQsFAAOCAQEAcODYINxv
Digo62XfFCZWQBcm5iZiOWxU8wZ5uCi9TGCgZxEh0+GkaZkRv/PeBGzEqv/yIxFi
6CJmpPSLGrc8TNF7/+7p3F0dBftpXKe7mWV/VG/GHaDKFqU8HJv4L3oyIS5+hi8L
SCflgi/66BGNk2+AzXqDJiR/OWGz3lREHNsfOVdeE0YaAw3+ssaPdOEcNqSTST7M
cwQum+Eu9dWnqhHrDuzII+YgytFYh5Rmwar84+S2N6cKn9/rfIt5R3xi0pLL2QUs
+B2qL06zDdCBliAn9ohzxfnboQZPCtaimvSfFAwVyqWZfgN1VQ7IaJ/2gMUd121g
1aPRKygslsNMNQ=='''.stripIndent().trim()

        KUBE_CLUSTER = 'minikube'
        KUBE_CONTEXT = 'minikube'
        KUBE_CREDENTIALS = 'minikube-jenkins-secret'
        KUBE_NAMESPACE = 'dev'
        KUBE_SERVER_URL = 'https://192.168.49.2:8443'
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

        stage('Deploy to Sandbox') {
            when {
                branch 'dev'
            }
            steps {
                withKubeConfig(
                    caCertificate: env.KUBE_CA_CERT,
                    clusterName: env.KUBE_CLUSTER,
                    contextName: env.KUBE_CONTEXT,
                    credentialsId: env.KUBE_CREDENTIALS,
                    namespace: env.KUBE_NAMESPACE,
                    restrictKubeConfigAccess: false,
                    serverUrl: env.KUBE_SERVER_URL) {
                    script {

                        // Define the dynamic values
                        env.APP_NAME = "community-watch-web-sandbox"
                        env.DEPLOYMENT_NAME = "community-watch-web-sandbox"
                        env.CONTAINER_NAME = "community-watch-web"
                        // IMAGE_NAME and IMAGE_TAG are already in your global env block

                        // 1. Use envsubst to swap variables in the YAML
                        // 2. Apply the resulting configuration

                        sh "envsubst < community-watch-web-sandbox.yaml > prepared-sandbox.yaml"
                        sh "kubectl apply -f prepared-sandbox.yaml"
                    }
                }
            }
        }


        stage('Deploy to Dev') {
            when {
                branch 'main'
            }
            steps {
                withKubeConfig(
                    caCertificate: env.KUBE_CA_CERT,
                    clusterName: env.KUBE_CLUSTER,
                    contextName: env.KUBE_CONTEXT,
                    credentialsId: env.KUBE_CREDENTIALS,
                    namespace: env.KUBE_NAMESPACE,
                    restrictKubeConfigAccess: false,
                    serverUrl: env.KUBE_SERVER_URL) {
                    script {
                        // Define the variables within the shell environment for envsubst
                        // IMAGE_NAME and IMAGE_TAG are already in your global env block
                        // 1. Use envsubst to swap variables in the YAML
                        // 2. Apply the resulting configuration
                        sh """
                            export APP_NAME="community-watch-web-dev"
                            export DEPLOYMENT_NAME="community-watch-web-dev"
                            export CONTAINER_NAME="community-watch-web"
                            envsubst < community-watch-web-dev.yaml > prepared-dev.yaml
                        """
                        sh "kubectl apply -f prepared-dev.yaml"
                    }
                }
            }
        }


        stage('Promote to UAT') {
            when {
                branch 'main'
            }
            steps {
                withKubeConfig(
                    caCertificate: env.KUBE_CA_CERT,
                    clusterName: env.KUBE_CLUSTER,
                    contextName: env.KUBE_CONTEXT,
                    credentialsId: env.KUBE_CREDENTIALS,
                    namespace: env.KUBE_NAMESPACE,
                    restrictKubeConfigAccess: false,
                    serverUrl: env.KUBE_SERVER_URL) {
                    script {
                        input message: "Deploy version ${IMAGE_TAG} to UAT?", ok: "Deploy to UAT"
                        // Define the variables within the shell environment for envsubst
                        // IMAGE_NAME and IMAGE_TAG are already in your global env block
                        // 1. Use envsubst to swap variables in the YAML
                        // 2. Apply the resulting configuration
                        sh """
                            export APP_NAME="community-watch-web-uat"
                            export DEPLOYMENT_NAME="community-watch-web-uat"
                            export CONTAINER_NAME="community-watch-web"
                            envsubst < community-watch-web-uat.yaml > prepared-uat.yaml
                        """
                        sh "kubectl apply -f prepared-uat.yaml"
                    }
                }
            }
        }


        stage('Promote to Prod') {
            when {
                branch 'main'
            }
            steps {
                withKubeConfig(
                    caCertificate: env.KUBE_CA_CERT,
                    clusterName: env.KUBE_CLUSTER,
                    contextName: env.KUBE_CONTEXT,
                    credentialsId: env.KUBE_CREDENTIALS,
                    namespace: env.KUBE_NAMESPACE,
                    restrictKubeConfigAccess: false,
                    serverUrl: env.KUBE_SERVER_URL) {
                    script {
                        input message: "Deploy version ${IMAGE_TAG} to PROD?", ok: "Deploy to PROD"
                        // Define the variables within the shell environment for envsubst
                        // IMAGE_NAME and IMAGE_TAG are already in your global env block
                        // 1. Use envsubst to swap variables in the YAML
                        // 2. Apply the resulting configuration
                        sh """
                            export APP_NAME="community-watch-web-prod"
                            export DEPLOYMENT_NAME="community-watch-web-prod"
                            export CONTAINER_NAME="community-watch-web"
                            export HPA_NAME="community-watch-web-prod-hpa"
                            envsubst < community-watch-web-prod.yaml > prepared-prod.yaml
                        """
                        sh "kubectl apply -f prepared-prod.yaml"
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