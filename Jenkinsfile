pipeline {

    agent any

    options {
        timestamps()
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
    }

    parameters {

        booleanParam(
            name: 'DEPLOY_INFRASTRUCTURE',
            defaultValue: false,
            description: 'Apply Terraform changes; keep false for plan only'
        )

        string(
            name: 'AWS_REGION',
            defaultValue: 'eu-north-1'
        )

        string(
            name: 'AWS_ACCOUNT_ID',
            defaultValue: '297681905216'
        )

        string(
            name: 'PROJECT_NAME',
            defaultValue: 'aws-ha-dr-lab'
        )

        string(
            name: 'ENVIRONMENT',
            defaultValue: 'dev'
        )

        string(
            name: 'AMI_ID',
            defaultValue: '',
            description: 'Not required for Network-only deployment'
        )

        string(
            name: 'NOTIFICATION_EMAIL',
            defaultValue: '',
            description: 'Not required for Network-only deployment'
        )

        string(
            name: 'DOMAIN_NAME',
            defaultValue: '',
            description: 'Not required for Network-only deployment'
        )

        string(
            name: 'APP_REPOSITORY_URL',
            defaultValue: '',
            description: 'Not required for Network-only deployment'
        )

        string(
            name: 'APP_REPOSITORY_BRANCH',
            defaultValue: 'main'
        )

        string(
            name: 'APP_DOCKER_CONTEXT',
            defaultValue: '.'
        )
    }

    environment {

        AWS_REGION = "${params.AWS_REGION}"
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"

        ECR_REGISTRY = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_REGION}.amazonaws.com"

        ECR_REPOSITORY = "${params.PROJECT_NAME}-${params.ENVIRONMENT}-app"

        IMAGE_URI = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_REGION}.amazonaws.com/${params.PROJECT_NAME}-${params.ENVIRONMENT}-app:${env.BUILD_NUMBER}"

        AWS_CREDENTIALS_ID = 'aws-ha-dr-aws-credentials'

        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
    }

    stages {

        stage('Checkout Infrastructure') {
            steps {
                checkout scm
            }
        }

        stage('Validate Inputs and Tools') {
            steps {
                bat '''
                    terraform version
                    aws --version
                    git --version
                '''
            }
        }

        stage('Terraform Format and Validate') {
            steps {

                bat 'terraform fmt -check -recursive'

                dir('network') {
                    bat '''
                        terraform init -backend=false -input=false
                        terraform validate
                    '''
                }
            }
        }

        stage('AWS Authentication') {
            steps {

                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {
                    bat 'aws sts get-caller-identity'
                }
            }
        }

        stage('Network Terraform Plan') {
            steps {
                tfDeploy('network', '')
            }
        }

        /*
        ============================================================
        TEMPORARILY DISABLED STAGES
        Enable these later after Network is successfully deployed.
        ============================================================

        stage('Checkout Application') {
            when {
                expression {
                    params.APP_REPOSITORY_URL?.trim()
                }
            }

            steps {
                dir('app-source') {
                    git branch: params.APP_REPOSITORY_BRANCH,
                        credentialsId: 'app-repository-credentials',
                        url: params.APP_REPOSITORY_URL
                }
            }
        }

        stage('Resolve AMI') {
            steps {
                script {
                    if (params.AMI_ID?.trim()) {
                        env.RESOLVED_AMI_ID = params.AMI_ID.trim()
                    } else {
                        withCredentials([
                            [
                                $class: 'AmazonWebServicesCredentialsBinding',
                                credentialsId: env.AWS_CREDENTIALS_ID
                            ]
                        ]) {
                            env.RESOLVED_AMI_ID = bat(
                                script: "aws ssm get-parameter --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query 'Parameter.Value' --output text",
                                returnStdout: true
                            ).trim()
                        }
                    }
                }
            }
        }

        stage('Database') {
            steps {
                tfDeploy('database', '')
            }
        }

        stage('Application Base') {
            steps {
                tfDeploy(
                    'application',
                    "-var=app_image=${env.IMAGE_URI} -var=ami_id=${env.RESOLVED_AMI_ID} -var=enable_asg=false"
                )
            }
        }

        stage('Build and Push Image') {
            steps {
                dir('app-source') {
                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {
                        bat '''
                            set -eu

                            test -f Dockerfile

                            aws ecr describe-repositories \
                                --repository-names "$ECR_REPOSITORY" \
                                >/dev/null 2>&1 || \
                            aws ecr create-repository \
                                --repository-name "$ECR_REPOSITORY" \
                                --image-scanning-configuration scanOnPush=true

                            aws ecr get-login-password |
                                docker login \
                                --username AWS \
                                --password-stdin "$ECR_REGISTRY"

                            docker build -t "$IMAGE_URI" "$APP_DOCKER_CONTEXT"

                            docker push "$IMAGE_URI"
                        '''
                    }
                }
            }
        }

        stage('Application ASG') {
            steps {
                tfDeploy(
                    'application',
                    "-var=app_image=${env.IMAGE_URI} -var=ami_id=${env.RESOLVED_AMI_ID} -var=enable_asg=true"
                )
            }
        }

        stage('Monitoring') {
            steps {
                tfDeploy(
                    'monitoring',
                    "-var=notification_email=${params.NOTIFICATION_EMAIL}"
                )
            }
        }

        stage('Security') {
            steps {
                tfDeploy('security', '')
            }
        }

        stage('DNS and HTTPS') {
            when {
                expression {
                    params.DOMAIN_NAME?.trim()
                }
            }

            steps {
                tfDeploy(
                    'dns-https',
                    "-var=domain_name=${params.DOMAIN_NAME}"
                )
            }
        }

        */
    }

    post {
        always {
            bat 'docker logout "$ECR_REGISTRY" || true'
            deleteDir()
        }
    }
}

def tfDeploy(String module, String extraVars) {

    dir(module) {

        withCredentials([
            [
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: env.AWS_CREDENTIALS_ID
            ]
        ]) {

            bat """
                terraform init -input=false

                terraform plan \
                    -input=false \
                    -out=tfplan \
                    ${extraVars}
            """

            if (params.DEPLOY_INFRASTRUCTURE) {
                bat 'terraform apply -input=false -auto-approve tfplan'
            }
        }
    }
}
