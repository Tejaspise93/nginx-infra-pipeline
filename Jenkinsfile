pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Select action to perform'
        )
    }

    environment {
        TF_DIR      = 'terraform'
        ANSIBLE_DIR = 'ansible'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Wait for Instances') {   // wait for instances to be up before running Ansible
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo 'Waiting 60 seconds for instances to boot...'
                sh 'sleep 60'
            }
        }

        stage('Ansible Playbook') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '/var/lib/jenkins/.local/bin/ansible-playbook -i inventory.ini nginx_playbook.yml'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed — check logs above"
        }
    }
}