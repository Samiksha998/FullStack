pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS  = credentials('dockerhub-creds')
        DOCKERHUB_USERNAME     = 'samikshav'
        FRONTEND_REPO          = 'samikshav/frontend'
        BACKEND_REPO           = 'samikshav/backend'
        KUBECONFIG             = '/home/ec2-user/.kube/config'

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

        stage('Start Minikube') {
            steps {
                echo '[INFO] Verifying Minikube status...'
                sh '''
                    export KUBECONFIG=${KUBECONFIG}
                    if ! minikube status | grep -q "host: Running"; then
                        echo "[INFO] Starting Minikube with none driver..."
                        sudo -n /usr/bin/minikube start --driver=none || {
                          echo "[ERROR] Minikube failed to start. Check sudoers config.";
                          exit 1;
                        }
                    else
                        echo "[INFO] Minikube is already running."
                    fi
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                echo '[INFO] Building Docker images for frontend and backend...'
                sh '''
                    docker build -t ${FRONTEND_REPO}:latest ./frontend
                    docker build -t ${BACKEND_REPO}:latest ./backend
                '''
            }
        }

        stage('Deploy PostgreSQL') {
            steps {
                echo '[INFO] Deploying PostgreSQL...'
                sh '''
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl apply -f kubernetes/postgres-pvc.yaml
                    kubectl apply -f kubernetes/postgres-deployment.yaml
                    kubectl apply -f kubernetes/postgres-service.yaml
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                echo '[INFO] Deploying frontend and backend...'
                sh '''
                    export KUBECONFIG=${KUBECONFIG}
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
