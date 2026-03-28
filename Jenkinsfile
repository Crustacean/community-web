def dockerImage = ''

pipeline {
    agent any

    environment {
        IMAGE_NAME = "em22435/community-watch-web".toLowerCase()
        IMAGE_TAG  = "${env.BUILD_NUMBER}"

        KUBE_CA_CERT = '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
    a3ViZUNBMB4XDTI2MDMyNDE0NDU0OFoXDTM2MDMyMjE0NDU0OFowFTETMBEGA1UE
    AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALQ1
    3lFtbOkhvzPOs9bO4gchYGUDa1v3VEs6ZeyDsVuSiUKdueRlQrm49x5JppjXqq+n
    GMsPq1uFNIwog9YGurslZ0vxiuKETdMUNRCsemhAnUao4AJBqGTVc1Mlisz5/Fc7
    fBNoOmFOWNpLGhOcTmj+smbGV81OVeJ+ehKtyps4qVd83U77IAx4AOhO/nUoGSYx
    E4xGdNLhEdLbDbJv2of6CaqYjRFs79qAkLhPNEpcIRFD9oCQ9DJchhlYvHQaXSpo
    4Z9XZJoBqLw2unV6i2CYdd+tvu5XBr3ZiYZldEGWkC5t2ylRvg+TD9jM89DbUOmL
    n6E7ce/Mmyq9sGxBoasCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
    MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
    BBRUAzROVWcNCaFxASiVKjTL3kM2yTANBgkqhkiG9w0BAQsFAAOCAQEAsWGCnnS5
    x5J4aVIbkAu4+t8Kodr7tLnsFchVNkZy6OrvuZhDtQum/LADhnf4rOQRdZDA6XCr
    cDPGmq45j96Eg+fAIybwctPKnC1a9aD4Dh7UaqcX5WXNzRlX4sbAi47oubteTQy8
    mo9kSx1CSJUMhEYwu/wnvXxJLX70zWAcytySJyOt7FIKa4/cjOM1uHA5XF6en8L3
    Cuvjfd2hO6svfHCa7vbxumT/StIXjQluVIfMS8jXBnqbbadDoNRhqhZSbvlmE7Zj
    NqJjavhjkXuVRRjJlP5Dp04QwhGJM375YGxQKVUmhYZHzkDQy2+y8jCezmYLIuus
    ybjER0RZivXFdA=='''

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
                        env.APP_NAME = "community-watch"
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
                        sh "envsubst < community-watch-web-dev.yaml > prepared-dev.yaml"
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
                        sh "envsubst < community-watch-web-uat.yaml > prepared-uat.yaml"
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
                        sh "envsubst < community-watch-web-prod.yaml > prepared-prod.yaml"
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