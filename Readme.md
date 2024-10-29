# SWE645 Assignment 2

## Name: Rudra Chauhan

This project demonstrates containerizing a web application using Docker, pushing it to DockerHub, and preparing it for deployment on Kubernetes. The instructions cover building and running the containerized application locally, and further steps for Kubernetes deployment.

## Project Directory Structure

```
Assignment2
├── my-website        # Folder containing web application files
├── Dockerfile        # Docker configuration for containerizing the web application
├── Jenkinsfile      # Jenkins configuration for CI/CD pipeline
├── service.yaml     # Kubernetes Service configuration
├── deployment.yaml  # Kubernetes Deployment configuration
└── README.md        # Project README file
```

## Step 1: Containerizing Web Application

### Prerequisites

- Docker Desktop installed and running
- Basic understanding of containerization concepts

### Dockerfile

The Dockerfile defines the instructions to build a container image for the web application using the Nginx server.

```dockerfile
# Use the Nginx image from Docker Hub
FROM nginx:alpine

# Set the working directory to nginx asset directory
WORKDIR /usr/share/nginx/html

# Remove the default nginx static assets
RUN rm -rf ./*

# Copy static assets from the web application folder
COPY ./my-website .

# Containers run nginx with global directives and daemon off
CMD ["nginx", "-g", "daemon off;"]
```

### Building and Running the Container

To build and run the container locally, use the following commands:

```bash
# Build the Docker image
docker build -t <container-name> .

# Run the container on host port 8090
docker run -p 8090:80 <container-name>

# Verify running containers
docker ps
```

- `docker build -t <container-name> .` - Builds the Docker image from the Dockerfile.
- `docker run -p 8090:80 <container-name>` - Runs the container, mapping host port `8090` to container port `80`.
- `docker ps` - Lists running containers.

### Access the Application

Once running, the web application will be accessible at `http://localhost:8090`. Verify that your website loads correctly and all functionality works as expected.

## Step 2: Push the Container to DockerHub

### Prerequisites

- DockerHub account
- Docker CLI logged in to your DockerHub account

To make the container accessible to Kubernetes or other deployment platforms, push it to DockerHub:

1. Log in to DockerHub:

```bash
docker login
```

2. Tag the container with your DockerHub repository name:

```bash
docker tag <container-name> <your-dockerhub-username>/<container-name>
```

3. Push the container to DockerHub:

```bash
docker push <your-dockerhub-username>/<container-name>
```

Verify that your image appears in your DockerHub repository before proceeding to the next step.

## Step 3: AWS EKS Setup and Deployment

### Prerequisites

- AWS Account (or AWS Learner Lab access)
- AWS CLI installed
- kubectl installed

### Creating EKS Cluster

1. Navigate to AWS Management Console:

   - Search for "EKS" or find it under Services
   - Ensure you're in your desired region (e.g., us-east-1)

2. Create EKS Cluster:

   - Click "Create cluster"
   - Provide a cluster name
   - Select Kubernetes version (latest stable recommended)
   - Use default IAM LabRole
   - Keep default VPC and subnet configurations
   - For demo purposes, you can use default security group settings

3. Create Node Group:
   - After cluster creation, navigate to the "Compute" tab
   - Click "Add Node Group"
   - Configure node group settings:
     - Name your node group
     - Choose instance type (t3.medium recommended for testing)
     - Set scaling configuration (e.g Min: 1, Max: 1)
     - Review and create

Note: Cluster creation takes approximately 15-20 minutes. Node group creation takes an additional 5-10 minutes.

### Connecting to Kubernetes Cluster

1. Configure AWS CLI:

   ```bash
   aws configure
   ```

   When prompted, enter:

   - AWS Access Key ID
   - AWS Secret Access Key
   - Region (e.g., us-east-1)
   - Output format (json)

   Note: Access key, secret key, and session token can be found in AWS Learner Lab's "AWS Details" section:

   - Click "AWS Details"
   - Copy Access key, Secret key, and Session token

   For AWS Learner Lab users:

   ```bash
   # Set session token (required for Learner Lab)
   aws configure set aws_session_token <session-token>
   ```

2. Update Kubernetes Configuration:

   ```bash
   aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
   ```

   This updates your `.kube/config` file (typically located at `C:/Users/<current-username>/.kube`)

3. Verify Connection:
   ```bash
   kubectl get nodes
   ```
   Should display your node(s) in "Ready" state.

### Kubernetes Deployment Configuration

1. Create `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-website
  labels:
    app: my-website
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-website
  template:
    metadata:
      labels:
        app: my-website
    spec:
      containers:
        - name: my-website
          image: rudra2807/swe645-assignment2:latest
          ports:
            - containerPort: 80
```

2. Create `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-website-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: my-website
```

3. Apply and Verify Deployment:

```bash
# Apply configurations
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Verify deployment status
# View deployments
kubectl get deployments

# View pods
kubectl get pods

# View services (includes LoadBalancer external IP)
kubectl get services

# View detailed information
kubectl describe deployment my-website
kubectl describe service my-website-service

# View pod logs
kubectl logs <pod-name>
```

The LoadBalancer external IP can take a few minutes to provision. Once available, your website will be accessible through this IP.

## Step 4: CI/CD Pipeline with Jenkins

### Prerequisites

- Jenkins installed and running
- GitHub repository with your project
- Basic understanding of CI/CD concepts

### Jenkins Setup

1. Install Jenkins:

   - Download and install Jenkins from official website
   - Install required plugins:
     - Git plugin
     - Pipeline plugin
     - Docker Pipeline plugin
     - Kubernetes Continuous Deploy plugin

2. Configure Jenkins Credentials:

   - Navigate to "Manage Jenkins" → "Manage Credentials"
   - Add credentials for:
     - GitHub
     - DockerHub
     - AWS (if using programmatic deployment)
   - Note: Keep the domain "Global"

3. Create Pipeline:

   - Click "New Item"
   - Choose "Pipeline"
   - Configure:
     - Enable "GitHub hook trigger for GITScm polling"
     - Under Pipeline Configuration:
       - Definition: "Pipeline script from SCM"
       - SCM: Git
       - Repository URL: Your GitHub repo URL
       - Credentials: Select GitHub credentials
       - Branch Specifier: \*/master (or your main branch)
       - Script Path: Jenkinsfile

4. Create `Jenkinsfile` in your repository:

```groovy
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = ''  // Replace with your Docker image name
        DOCKER_TAG = 'latest'
        KUBECONFIG_PATH = ''  // Replace with your kubeconfig path
    }
    stages {
        stage('Clone Repository') {
            steps {
                // Clone the repository
                git branch: 'main',
                    credentialsId: '',  // Add your GitHub credentials ID
                    url: ''  // Add your repository URL
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }
        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(credentialsId: '',  // Add your DockerHub credentials ID
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASS')
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
```

#### Special Configuration for AWS Learner Lab Users

When using AWS Learner Lab, you need to manually modify the kubeconfig file to include your AWS credentials. The file is typically located at:

- Windows: `%UserProfile%\.kube\config`
- Linux/Mac: `~/.kube/config`

1. Update the kubeconfig file with the following structure:

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: ""
      server: https://EA4BAFE2AB12E04FBC530AD382793BF1.gr7.us-east-1.eks.amazonaws.com
    name: arn:aws:eks:us-east-1:943197202758:cluster/swe645Cluster
contexts:
  - context:
      cluster: arn:aws:eks:us-east-1:943197202758:cluster/swe645Cluster
      user: arn:aws:eks:us-east-1:943197202758:cluster/swe645Cluster
    name: arn:aws:eks:us-east-1:943197202758:cluster/swe645Cluster
current-context: arn:aws:eks:us-east-1:943197202758:cluster/swe645Cluster
kind: Config
preferences: {}
users:
  - name: arn:aws:eks:us-east-1:943197202758:cluster/swe645Cluster
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1beta1
        args:
          - --region
          - us-east-1
          - eks
          - get-token
          - --cluster-name
          - swe645Cluster
        command: aws
        env:
          - name: AWS_ACCESS_KEY_ID
            value: "" # Add your AWS access key here
          - name: AWS_SECRET_ACCESS_KEY
            value: "" # Add your AWS secret key here
          - name: AWS_SESSION_TOKEN
            value: "" # Add your AWS session token here
```

Important Notes:

1. The `env` section under `users` is crucial for AWS Learner Lab authentication
2. You must update these credentials every time you:
   - Start a new Learner Lab session
   - Resume a suspended session
   - After session timeout

To update credentials:

1. Go to AWS Learner Lab dashboard
2. Click "AWS Details"
3. Copy the new:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_SESSION_TOKEN
4. Update these values in your kubeconfig file

Important Notes for Jenkinsfile:

1. Replace `DOCKER_IMAGE` with your Docker image name
2. Add your GitHub `credentialsId` in the Clone Repository stage
3. Add your repository URL in the Clone Repository stage
4. Add your DockerHub `credentialsId` in the Push to DockerHub stage
5. Ensure the kubeconfig path matches your Jenkins server configuration

6. ### Setting Up GitHub Webhook with ngrok

To enable automatic build triggers when you push to GitHub, you need to configure a webhook. Since Jenkins is running locally, we'll use ngrok to create a public endpoint.

1. Install ngrok:

   - Download from [ngrok website](https://ngrok.com/)
   - Extract the executable
   - Add to system PATH (optional)

2. Create Public Endpoint:

   ```bash
   # Replace <jenkins-port> with your Jenkins port (typically 8080)
   ngrok http <jenkins-port>
   ```

   ngrok will display a forwarding URL like:

   ```
   Forwarding  https://abc123.ngrok.io -> localhost:8080
   ```

3. Configure GitHub Webhook:
   - Go to your GitHub repository
   - Navigate to Settings → Webhooks
   - Click "Add webhook"
   - Configure webhook:
     - Payload URL: `https://abc123.ngrok.io/github-webhook/`
     - Content type: application/json
     - Which events?: Select "Just the push event"
     - Active: Check the box
   - Click "Add webhook"

### Automated Deployment Process

1. Developer pushes code to GitHub
2. GitHub webhook triggers Jenkins pipeline
3. Jenkins:
   - Builds new Docker image
   - Pushes to DockerHub
   - Updates Kubernetes deployment
4. Kubernetes:
   - Pulls new image
   - Updates pods with zero-downtime deployment
   - Routes traffic through LoadBalancer
