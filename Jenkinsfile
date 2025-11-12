//Jenkinsfile placeholder - full pipeline added here
pipeline {
  agent any

  environment {
    AWS_REGION  = 'ap-south-1'
    ECR_REPO    = 'flask-ml-api'
    IMAGE_TAG   = "${env.BUILD_NUMBER}"
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
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            echo "Logging in to AWS ECR..."
            ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
            ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
            echo "ECR URI: ${ECR_URI}"

            aws ecr get-login-password --region ${AWS_REGION} | \
            docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

            echo ${ECR_URI} > ecr_uri.txt
          '''
        }
      }
    }
    stage('Ensure ECR Repository') {
        steps {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
            sh '''
                echo "Checking if ECR repo ${ECR_REPO} exists..."
                ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
                aws ecr describe-repositories --repository-names ${ECR_REPO} --region ${AWS_REGION} || \
                aws ecr create-repository --repository-name ${ECR_REPO} --region ${AWS_REGION}
            '''
            }
        }
    }


    stage('Push to ECR') {
      steps {
        sh '''
          ECR_URI=$(cat ecr_uri.txt)
          echo "Tagging and pushing image to ${ECR_URI}:${IMAGE_TAG}..."
          docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
          docker push ${ECR_URI}:${IMAGE_TAG}
        '''
      }
    }

    stage('Terraform Deploy') {
      steps {
        dir('terraform') {
          sh '''
            ECR_URI=$(cat ../ecr_uri.txt)
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
