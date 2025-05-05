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
        POSTGRES_USER          = 'admin'
        POSTGRES_PASSWORD      = 'admin@123'
        POSTGRES_DB            = 'employeedb'
        SONAR_HOST_URL         = 'http://13.217.45.105:9000' // replace with actual URL
        SONAR_TOKEN            = credentials('sonar-token')          // Jenkins secret text credential ID
    }

    stages {
        stage('Checkout') {
            steps {
                echo '[INFO] Cloning repository...'
                git url: 'https://github.com/Samiksha998/FullStack.git', branch: 'main'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '[INFO] Running SonarQube analysis for frontend and backend...'
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=backend-app \
                          -Dsonar.sources=docker/backend \
                          -Dsonar.projectBaseDir=docker/backend \
                          -Dsonar.host.url=$SONAR_HOST_URL \
                          -Dsonar.login=$SONAR_TOKEN

                        sonar-scanner \
                          -Dsonar.projectKey=frontend-app \
                          -Dsonar.sources=docker/frontend \
                          -Dsonar.projectBaseDir=docker/frontend \
                          -Dsonar.host.url=$SONAR_HOST_URL \
                          -Dsonar.login=$SONAR_TOKEN
                    '''
                }
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
                    aws eks update-kubeconfig --region "$AWS_DEFAULT_REGION" --name "$CLUSTER_NAME" --kubeconfig "$KUBECONFIG_PATH"
                    chmod 600 "$KUBECONFIG_PATH"

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
                    aws eks update-kubeconfig --region "$AWS_DEFAULT_REGION" --name "$CLUSTER_NAME" --kubeconfig "$KUBECONFIG_PATH"
                    chmod 600 "$KUBECONFIG_PATH"

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
