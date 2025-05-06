pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS  = credentials('dockerhub-creds')
        DOCKERHUB_USERNAME     = 'samikshav'
        FRONTEND_REPO          = 'samikshav/frontend'
        BACKEND_REPO           = 'samikshav/backend'
        KUBECONFIG_PATH        = "${HOME}/.kube/config"

        POSTGRES_USER          = 'postgres'
        POSTGRES_PASSWORD      = 'admin123'
        POSTGRES_DB            = 'employees'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '[INFO] Cloning repository...'
                git url: 'https://github.com/Samiksha998/FullStack.git', branch: 'main'
            }
        }

        stage('Check Docker Context') {
            steps {
                echo '[INFO] Verifying Docker context for Minikube...'
                sh '''
                    echo "[INFO] Checking Minikube status..."
                    minikube status || minikube start

                    echo "[INFO] Setting Docker environment..."
                    eval $(minikube docker-env) || { echo "[ERROR] Failed to set docker-env"; exit 1; }

                    docker info
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                echo '[INFO] Building Docker images for frontend and backend...'
                sh '''
                    eval $(minikube docker-env)
                    docker build -t ${FRONTEND_REPO}:latest ./frontend
                    docker build -t ${BACKEND_REPO}:latest ./backend
                '''
            }
        }

        stage('Deploy PostgreSQL on Minikube') {
            steps {
                echo '[INFO] Deploying PostgreSQL on Minikube...'
                sh '''
                    kubectl apply -f kubernetes/postgres-pvc.yaml
                    kubectl apply -f kubernetes/postgres-deployment.yaml
                    kubectl apply -f kubernetes/postgres-service.yaml
                '''
            }
        }

        stage('Deploy App to Minikube') {
            steps {
                echo '[INFO] Deploying backend and frontend to Minikube...'
                sh '''
                    kubectl apply -f kubernetes/postgres-pv.yaml
                    kubectl apply -f kubernetes/backend-deployment.yaml
                    kubectl apply -f kubernetes/frontend-deployment.yaml
                    kubectl apply -f kubernetes/backend-service.yaml
                    kubectl apply -f kubernetes/frontend-service.yaml
                '''
            }
        }
    }

    post {
        always {
            echo '[INFO] Cleaning up workspace...'
            // cleanWs()
        }
        failure {
            echo '[ERROR] Pipeline failed.'
        }
        success {
            echo '[SUCCESS] Deployment to Minikube completed successfully.'
        }
    }
}
