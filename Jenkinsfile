pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform action'
        )
        choice(
            name: 'INSTANCE_TYPE',
            choices: ['t2.micro', 't2.small', 't2.medium', 't3.micro'],
            description: 'EC2 Instance Type'
        )
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Deployment Environment'
        )
        string(
            name: 'INSTANCE_NAME',
            defaultValue: 'jenkins-ec2',
            description: 'Name for EC2 instance'
        )
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Checking out Terraform code..."
                git branch: 'main',
                    url: 'https://github.com/your-org/your-terraform-repo.git'
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
                echo "Validating Terraform configuration..."
                sh 'terraform validate'
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "Checking Terraform formatting..."
                sh 'terraform fmt -check'
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
                    input message: """
                        ⚠️ Confirm Terraform ${params.ACTION.toUpperCase()}
                        Instance: ${params.INSTANCE_NAME}
                        Type:     ${params.INSTANCE_TYPE}
                        Env:      ${params.ENVIRONMENT}
                        Proceed?
                    """, ok: "Yes, ${params.ACTION}!"
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo "Applying Terraform changes..."
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                echo "Destroying infrastructure..."
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
                echo "Fetching EC2 details..."
                sh '''
                    echo "=============================="
                    echo "   EC2 Instance Details"
                    echo "=============================="
                    terraform output
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline SUCCESS: Terraform ${params.ACTION} completed!"
        }
        failure {
            echo "❌ Pipeline FAILED: Check logs above for errors."
        }
        aborted {
            echo "⚠️ Pipeline ABORTED: Action was cancelled."
        }
        always {
            echo "Pipeline finished. Cleaning workspace..."
            cleanWs()
        }
    }
}
