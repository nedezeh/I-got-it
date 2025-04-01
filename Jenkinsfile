pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
        AWS_DEFAULT_REGION = "us-east-1" // Change this if you use another region
    }

    stages {

        // Clone GitHub Repo
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/nedezeh/AWS-Security-tool20.git'
            }
        }

        // Terraform Init
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        // Terraform Validate
        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        // Terraform Plan
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        // Terraform Apply
        stage('Terraform Apply') {
            steps {
                input "Do you want to apply the changes?" // Jenkins will wait for your approval
                sh 'terraform apply -auto-approve'
            }
        }
    }

    // ✅ Post actions: send email notification after pipeline finishes
    post {
        success {
            mail to: 'johnezeh100@gmail.com',
                 subject: "Jenkins Job Success: ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                 body: "Good news! The Jenkins job '${env.JOB_NAME}' build #${env.BUILD_NUMBER} was successful.\n\n Check Jenkins for more details: ${env.BUILD_URL}"
        }
        failure {
            mail to: 'johnezeh100@gmail.com',
                 subject: "Jenkins Job Failed: ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                 body: "Attention! The Jenkins job '${env.JOB_NAME}' build #${env.BUILD_NUMBER} has failed.\n\n Check Jenkins for more details: ${env.BUILD_URL}"
        }
    }
}