# Jenkinsfile placeholder - full pipeline added here
pipeline {
  agent any

  environment {
    AWS_REGION     = 'ap-south-1'
    ECR_REPO       = 'flask-ml-api'
    AWS_ACCOUNT_ID = credentials('aws-creds')  // Jenkins credential (string)
    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    ECR_URI        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          echo "Building Docker image..."
          docker build -t ${ECR_REPO}:${IMAGE_TAG} ./app
        '''
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
          echo "Logging in to AWS ECR..."
          aws ecr get-login-password --region ${AWS_REGION} \
          | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          echo "Pushing image to ECR..."
          docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
          docker push ${ECR_URI}:${IMAGE_TAG}
        '''
      }
    }

    stage('Terraform Deploy') {
      steps {
        dir('terraform') {
          sh '''
            echo "Initializing Terraform..."
            terraform init -reconfigure
            echo "Applying Terraform changes..."
            terraform apply -auto-approve \
              -var "ecr_repo_url=${ECR_URI}" \
              -var "image_tag=${IMAGE_TAG}"
          '''
        }
      }
    }
  }

  post {
    success {
      echo '✅ Deployment completed successfully!'
    }
    failure {
      echo '❌ Pipeline failed. Check logs.'
    }
  }
}
