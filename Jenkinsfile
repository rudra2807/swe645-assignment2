pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'rudra2807/swe645-assignment2'
        DOCKER_TAG = 'latest'
        KUBECONFIG_PATH = 'C:\\Program Files\\Jenkins\\kubeconfig'
    }
    stages {
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
                    // Login to DockerHub (if not logged in)
                    bat "echo logging into Docker Hub..."
                    bat "docker login --username rudra2807 --password 
                    // Pushing image to DockerHub
                    bat "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                // Using the Kubeconfig to update the Kubernetes deployment
                bat "kubectl set image deployment/my-deployment my-container=${DOCKER_IMAGE}:${DOCKER_TAG} --kubeconfig=${KUBECONFIG_PATH}"
            }
        }
    }
}
