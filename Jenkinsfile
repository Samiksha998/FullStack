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
        CLUSTER_NAME           = 'Fullstack-cluster'
        KUBECONFIG_PATH        = "${WORKSPACE}/kubeconfig"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '[INFO] Cloning FullStack repository...'
                git url: 'https://github.com/Samiksha998/FullStack.git', branch: 'main'
            }
        }

        stage('Build Docker Images') {
            steps {
                echo '[INFO] Building Docker images for frontend and backend...'
                sh '''
                    docker build -t $FRONTEND_REPO:latest ./docker/frontend
                    docker build -t $BACKEND_REPO:latest ./docker/backend
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

        stage('Push Docker Images') {
            steps {
                echo '[INFO] Pushing Docker images to DockerHub...'
                sh '''
                    docker push $FRONTEND_REPO:latest
                    docker push $BACKEND_REPO:latest
                '''
            }
        }

        stage('Update kubeconfig') {
            steps {
                echo '[INFO] Configuring access to EKS cluster...'
                sh '''
                    aws eks update-kubeconfig --region "$AWS_DEFAULT_REGION" --name "$CLUSTER_NAME" --kubeconfig "$KUBECONFIG_PATH"
                    chmod 600 "$KUBECONFIG_PATH"
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo '[INFO] Applying Kubernetes manifests to EKS...'
                sh '''
                    KUBECONFIG="$KUBECONFIG_PATH" kubectl apply -f kubernetes/k8s.yaml
                '''
            }
        }
    }

    post {
        always {
            echo '[INFO] Cleaning workspace...'
            // cleanWs()
        }
        success {
            echo '[SUCCESS] Application successfully deployed to EKS!'
        }
        failure {
            echo '[ERROR] Pipeline execution failed.'
        }
    }
}
