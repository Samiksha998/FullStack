pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID      = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY  = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION     = "us-east-1"
        DOCKERHUB_CREDENTIALS  = credentials('dockerhub-creds')
        DOCKERHUB_USERNAME     = 'samikshav'
        FRONTEND_REPO          = 'samikshav/frontend'
        BACKEND_REPO           = 'samikshav/backend'
        CLUSTER_NAME           = "myapp-eks-cluster"
        KUBECONFIG_PATH        = "${WORKSPACE}/kubeconfig"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Samiksha998/FullStack.git', branch: 'main'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Build both frontend and backend images
                    sh 'sudo docker build -t $DOCKERHUB_USERNAME/frontend:latest ./docker/frontend'
                    sh 'sudo docker build -t $DOCKERHUB_USERNAME/backend:latest ./docker/backend'
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                script {
                    // Use the credentials stored in Jenkins for DockerHub login
                    sh '''
                        echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                    '''
                }
            }
        }

        stage('Push Images to DockerHub') {
            steps {
                script {
                    // Push images to DockerHub
                    sh 'sudo docker push $DOCKERHUB_USERNAME/frontend:latest'
                    sh 'sudo docker push $DOCKERHUB_USERNAME/backend:latest'
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    // Update and secure kubeconfig, then deploy to EKS
                    dir('kubernetes') {
                        sh '''
                            echo "[INFO] Updating kubeconfig..."
                            aws eks update-kubeconfig --region "$AWS_DEFAULT_REGION" --name "$CLUSTER_NAME" --kubeconfig "$KUBECONFIG_PATH"

                            echo "[INFO] Securing kubeconfig..."
                            chmod 600 "$KUBECONFIG_PATH"

                            echo "[INFO] Deploying to EKS..."
                            # Deploy backend and frontend
                            KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f k8s/backend-deployment.yaml
                            KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f k8s/frontend-deployment.yaml

                            # Apply service files for backend and frontend
                            KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f k8s/backend-service.yaml
                            KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f k8s/frontend-service.yaml
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean workspace after the pipeline run
            cleanWs()
        }
    }
}
