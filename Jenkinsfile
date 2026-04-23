pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AKIAX7566ZEVWPUZOQFF')
        AWS_SECRET_ACCESS_KEY = credentials('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')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform action'
        )
        choice(
            name: 'INSTANCE_TYPE',
            choices: ['t2.micro', 't2.small', 't2.medium'],
            description: 'EC2 Instance Type'
        )
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Environment'
        )
        string(
            name: 'INSTANCE_NAME',
            defaultValue: 'jenkins-ec2',
            description: 'EC2 Instance Name'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out code..."
                checkout scm
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    echo "=== Terraform Version ==="
                    terraform -version

                    echo "=== AWS CLI Version ==="
                    aws --version

                    echo "=== AWS Identity ==="
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                echo "Initializing Terraform..."
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "Validating configuration..."
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "Running Terraform Plan..."
                sh """
                    terraform plan \
                        -var="instance_name=${params.INSTANCE_NAME}" \
                        -var="instance_type=${params.INSTANCE_TYPE}" \
                        -var="environment=${params.ENVIRONMENT}" \
                        -out=tfplan
                """
            }
        }

        stage('Approval Gate') {
            when {
                expression {
                    params.ACTION == 'apply' || params.ACTION == 'destroy'
                }
            }
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    input message: "Approve ${params.ACTION} for ${params.INSTANCE_NAME}?",
                          ok: "Yes, proceed!"
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo "Applying Terraform..."
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                sh """
                    terraform destroy -auto-approve \
                        -var="instance_name=${params.INSTANCE_NAME}" \
                        -var="instance_type=${params.INSTANCE_TYPE}" \
                        -var="environment=${params.ENVIRONMENT}"
                """
            }
        }

        stage('Show Outputs') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh 'terraform output'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline SUCCESS!"
        }
        failure {
            echo "❌ Pipeline FAILED! Check logs."
        }
        always {
            node('built-in') {        // fix for cleanWs missing context error
                cleanWs()
            }
        }
    }
}
