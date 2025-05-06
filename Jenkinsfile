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

        stage('Check Minikube Status') {
            steps {
                echo '[INFO] Checking Minikube status...'
                script {
                    def status = sh(script: "minikube status | grep -q 'host: Running'", returnStatus: true)
                    if (status != 0) {
                        echo '[WARNING] Minikube is not running. Skipping deployment stages.'
                        currentBuild.result = 'NOT_BUILT'
                        error('Minikube is not running.')
                    } else {
                        echo '[INFO] Minikube is running. Proceeding with deployment.'
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                echo '[INFO] Building Docker images for frontend and backend...'
                sh '''
                    docker build -t ${FRONTEND_REPO}:latest ./frontend
                    docker build -t ${BACKEND_REPO}:latest ./backend
                '''
