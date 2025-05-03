pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // Add your Docker Hub username and password
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
                sh 'docker build -t $FRONTEND_REPO:latest ./frontend'
                sh 'docker build -t $BACKEND_REPO:latest ./backend'
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
                sh 'docker push $FRONTEND_REPO:latest'
                sh 'docker push $BACKEND_REPO:latest'
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    dir('kubernetes') {
                        sh "aws eks update-kubeconfig --region us-east-1 --name myapp-eks-cluster"
                        sh '''
                            kubectl apply -f k8s/backend-deployment.yaml
                            kubectl apply -f k8s/frontend-deployment.yaml
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Cleans the workspace after the pipeline run
        }
    }
}
