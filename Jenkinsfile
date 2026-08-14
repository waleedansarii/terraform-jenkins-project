pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true' // Reduces verbose output in Jenkins logs
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'],
                    string(credentialsId: 'ssh-public-key', variable: 'TF_VAR_ssh_public_key')
                ]) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check -recursive' 
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'],
                    string(credentialsId: 'ssh-public-key', variable: 'TF_VAR_ssh_public_key')
                ]) {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Review the Terraform plan in Jenkins logs. Proceed with Apply?', ok: 'Approve Deployment'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'],
                    string(credentialsId: 'ssh-public-key', variable: 'TF_VAR_ssh_public_key')
                ]) {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs() // Cleans up workspace to prevent state file conflicts on next run
        }
    }
}
