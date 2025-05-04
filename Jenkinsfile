pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        DOCKERHUB_USERNAME = 'samikshav'
        FRONTEND_REPO = 'samikshav/frontend'
        BACKEND_REPO = 'samikshav/backend'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Samiksha998/FullStack.git', branch: 'main'
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'sudo docker build -t samikshav/frontend:latest ./docker/frontend'
                sh 'sudo docker build -t samikshav/backend:latest ./docker/backend'
            }
        }

        stage('Login to DockerHub') {
            steps {
                sh '''
                    echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                '''
            }
        }

        stage('Push Images to DockerHub') {
            steps {
                sh 'sudo docker push samikshav/frontend:latest'
                sh 'sudo docker push samikshav/backend:latest'
            }
        }

        stage('Deploy to EKS with Terraform') {
            steps {
                script {
                    dir('terraform') {
                        // Initialize and apply Terraform
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'

                        // Get the Kubeconfig for EKS and update it
                        sh "aws eks update-kubeconfig --name myapp-eks-cluster --region us-east-1"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withEnv(["KUBECONFIG=${WORKSPACE}/kubeconfig"]) {
                    // Ensure the kubeconfig file is written correctly
                    writeFile file: 'kubeconfig', text: env.KUBECONFIG
                    
                    // Apply the Kubernetes manifests for frontend and backend deployments
                    sh '''
                    kubectl apply -f k8s/backend-deployment.yaml
                    kubectl apply -f k8s/frontend-deployment.yaml
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Clean workspace after the pipeline runs
        }
    }
}
