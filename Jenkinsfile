pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS  = credentials('dockerhub-creds')
        DOCKERHUB_USERNAME     = 'samikshav'
        FRONTEND_REPO          = 'samikshav/frontend'
        BACKEND_REPO           = 'samikshav/backend'
        KUBECONFIG             = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo '[INFO] Cloning FullStack repository...'
                git url: 'https://github.com/Samiksha998/FullStack.git', branch: 'main'
            }
        }

        stage('Build Docker Images') {
            steps {
                echo '[INFO] Building Docker images...'
                sh '''
                    docker build -t ${FRONTEND_REPO}:latest ./docker/frontend
                    docker build -t ${BACKEND_REPO}:latest ./docker/backend
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '[INFO] Pushing Docker images to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                        echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
                        docker push ${FRONTEND_REPO}:latest
                        docker push ${BACKEND_REPO}:latest
                    '''
                }
            }
        }

        stage('Deploy on Minikube') {
            steps {
                echo '[INFO] Starting Minikube tunnel and deploying...'
                sh '''
                    export KUBECONFIG=${KUBECONFIG}

                    echo '[INFO] Starting minikube tunnel in background...'
                    sudo -b nohup minikube tunnel > /tmp/tunnel.log 2>&1 &
                    sleep 10  # Wait for tunnel to establish

                    echo '[INFO] Verifying cluster and applying manifests...'
                    kubectl config current-context
                    kubectl get nodes
                    kubectl apply -f kubernetes/k8s.yaml
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
            echo '[SUCCESS] Application deployed to Minikube successfully!'
        }
    }
}
