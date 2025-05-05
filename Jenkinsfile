pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID      = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY  = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION     = 'us-east-1'
        DOCKERHUB_CREDENTIALS  = credentials('dockerhub-creds')
        DOCKERHUB_USERNAME     = 'samikshav'
        FRONTEND_REPO          = 'samikshav/frontend'
        BACKEND_REPO           = 'samikshav/backend'
        CLUSTER_NAME           = 'myapp-eks-cluster'
        KUBECONFIG_PATH        = "${WORKSPACE}/kubeconfig"
        
        // PostgreSQL credentials
        POSTGRES_USER          = 'admin'
        POSTGRES_PASSWORD      = 'admin@123'
        POSTGRES_DB            = 'employeedb'
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
                    sudo docker build -t $DOCKERHUB_USERNAME/frontend:latest ./docker/frontend
                    sudo docker build -t $DOCKERHUB_USERNAME/backend:latest ./docker/backend
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                echo '[INFO] Logging into DockerHub...'
                sh '''
                    echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                '''
            }
        }

        stage('Push Docker Images to DockerHub') {
            steps {
                echo '[INFO] Pushing Docker images to DockerHub...'
                sh '''
                    sudo docker push $DOCKERHUB_USERNAME/frontend:latest
                    sudo docker push $DOCKERHUB_USERNAME/backend:latest
                '''
            }
        }

        stage('Deploy PostgreSQL to EKS') {
            steps {
                echo '[INFO] Deploying PostgreSQL to EKS...'
                sh '''
                    echo "[INFO] Updating kubeconfig for PostgreSQL..."
                    aws eks update-kubeconfig --region "$AWS_DEFAULT_REGION" --name "$CLUSTER_NAME" --kubeconfig "$KUBECONFIG_PATH"
                    echo "[INFO] Securing kubeconfig..."
                    chmod 600 "$KUBECONFIG_PATH"

                    echo "[INFO] Deploying PostgreSQL Deployment and Service..."
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/postgres-pvc.yaml
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/postgres-deployment.yaml
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/postgres-service.yaml
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo '[INFO] Deploying backend and frontend to EKS...'
                sh '''
                    echo "[INFO] Updating kubeconfig..."
                    aws eks update-kubeconfig --region "$AWS_DEFAULT_REGION" --name "$CLUSTER_NAME" --kubeconfig "$KUBECONFIG_PATH"
                    echo "[INFO] Securing kubeconfig..."
                    chmod 600 "$KUBECONFIG_PATH"

                    echo "[INFO] Deploying backend and frontend services..."
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/postgres-pv.yaml
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/backend-deployment.yaml
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/frontend-deployment.yaml
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/backend-service.yaml
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/frontend-service.yaml
                '''
            }
        }
    }

    post {
        always {
            echo '[INFO] Cleaning up workspace...'
            // Uncomment to clean the workspace after execution
            // cleanWs()
        }
        failure {
            echo '[ERROR] Pipeline failed.'
        }
        success {
            echo '[SUCCESS] Deployment to EKS completed successfully.'
        }
    }
}
