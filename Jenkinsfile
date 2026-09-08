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

        // --- NEW ANSIBLE STAGE ---
        stage('Ansible Configuration') {
            steps {
                // Inject the SSH private key securely for Ansible to use
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'ec2-ssh-private-key', keyFileVariable: 'SSH_PRIV_KEY', usernameVariable: 'SSH_USER')
                ]) {
                    script {
                        // 1. Extract the public IP dynamically from Terraform state
                        def ec2_ip = sh(script: 'terraform output -raw ec2_public_ip', returnStdout: true).trim()
                        echo "Targeting EC2 Instance at IP: ${ec2_ip}"

                        // 2. Generate a temporary inventory file for Ansible
                        sh """
                            echo "[target_servers]" > temp_inventory.ini
                            echo "${ec2_ip} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_PRIV_KEY} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> temp_inventory.ini
                        """

                        // 3. (Optional) Ensure Ansible is installed on the Jenkins agent
                        sh 'sudo apt-get update && sudo apt-get install -y ansible'

                        // 4. Run the Ansible playbook
                        sh 'ansible-playbook -i temp_inventory.ini configure_ec2.yml'
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace, including the temporary inventory file
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
