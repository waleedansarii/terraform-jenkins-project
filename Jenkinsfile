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
                // Injects AWS credentials for provider authentication
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh 'terraform init'
                }
            }
        }

        // --- CI STAGES ---
        stage('Terraform Format Check') {
            steps {
                // fmt and validate do not strictly require AWS credentials
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
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        // --- MANUAL APPROVAL GATE ---
        stage('Manual Approval') {
            steps {
                input message: 'Review the Terraform plan in Jenkins logs. Proceed with Apply?', ok: 'Approve Deployment'
            }
        }

        // --- CD STAGE ---
        stage('Terraform Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace to prevent state file conflicts on next run
            cleanWs()
        }
    }
}
