pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'rudra2807/swe645-assignment2'
        DOCKER_TAG = 'latest'
        KUBECONFIG_PATH = 'C:\\Program Files\\Jenkins\\kubeconfig'
    }
    stages {
         stage('Clone Repository') {
            steps {
                // Clone the repository
                git branch: 'main',
                    credentialsId: 'github-credentials', 
                    url: 'https://github.com/rudra2807/swe645-assignment2.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Assuming Docker commands work directly if Docker CLI is configured
                    bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }
        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASS')
                    ]) {
                        bat "echo logging into Docker Hub..."
                        bat "echo | set /p=\"%DOCKER_PASS%\" | docker login --username %DOCKER_USERNAME% --password-stdin"
                        bat "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    }
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                // Using the Kubeconfig to update the Kubernetes deployment
                bat "kubectl set image deployment/my-website my-website=${DOCKER_IMAGE}:${DOCKER_TAG} --kubeconfig=\"C:\\Program Files\\Jenkins\\kubeconfig\""
                // Restart the pods to reflect the new changes
                bat "kubectl rollout restart deployment my-website --kubeconfig=\"C:\\Program Files\\Jenkins\\kubeconfig\""
            }
        }
    }
}
