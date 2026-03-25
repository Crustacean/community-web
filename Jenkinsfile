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
                    caCertificate: '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
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
ybjER0RZivXFdA==''', 
                    clusterName: 'minikube', 
                    contextName: 'minikube', 
                    credentialsId: 'minikube-jenkins-secret', 
                    namespace: 'dev', 
                    restrictKubeConfigAccess: false, 
                    serverUrl: 'https://192.168.49.2:8443'
                ) {
                    script {
                        sh "kubectl get ns"
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