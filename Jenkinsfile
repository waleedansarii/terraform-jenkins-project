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
                input message: 'Review the Terraform plan in Jenkins logs. Proceed with Apply and Ansible Configuration?', ok: 'Approve Deployment'
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

        stage('Ansible Configuration') {
            steps {
                // Combine BOTH AWS and SSH credentials in a SINGLE block
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'],
                    sshUserPrivateKey(credentialsId: 'ec2-ssh-private-key', keyFileVariable: 'SSH_PRIV_KEY', usernameVariable: 'SSH_USER')
                ]) {
                    script {
                        // Extract the public IP dynamically from Terraform state
                        def ec2_ip = sh(script: 'terraform output -raw ec2_public_ip', returnStdout: true).trim()
                        echo "Targeting EC2 Instance at IP: ${ec2_ip}"

                        // Generate temporary inventory
                        sh """
                            echo "[target_servers]" > temp_inventory.ini
                            echo "${ec2_ip} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_PRIV_KEY} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> temp_inventory.ini
                        """

                        // Ensure Ansible is installed
                        sh 'sudo apt-get update && sudo apt-get install -y ansible'

                        // Run Ansible playbook
                        sh 'ansible-playbook -i temp_inventory.ini configure_ec2.yml'
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs() 
        }
        success {
            echo '✅ Infrastructure provisioned and configured successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check console logs for details.'
        }
    }
}
