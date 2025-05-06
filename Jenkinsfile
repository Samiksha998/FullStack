pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS  = credentials('dockerhub-creds')
        DOCKERHUB_USERNAME     = 'samikshav'
        FRONTEND_REPO          = 'samikshav/frontend'
        BACKEND_REPO           = 'samikshav/backend'
        KUBECONFIG             = '/var/lib/jenkins/.kube/config'

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

        stage('Build Docker Images') {
            steps {
                echo '[INFO] Building Docker images for frontend and backend...'
                sh '''
                    docker build -t ${FRONTEND_REPO}:latest ./docker/frontend
                    docker build -t ${BACKEND_REPO}:latest ./docker/backend
                '''
            }
        }

        stage('Deploy PostgreSQL') {
            steps {
                echo '[INFO] Deploying PostgreSQL...'
                sh '''
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
        aborted {
            echo '[INFO] Pipeline was skipped because Minikube is not running.'
        }
    }
}
