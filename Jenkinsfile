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
            defaultValue: 'eu-north-1',
            description: 'AWS region'
        )

        string(
            name: 'AWS_ACCOUNT_ID',
            defaultValue: '297681905216',
            description: 'AWS account ID'
        )

        string(
            name: 'PROJECT_NAME',
            defaultValue: 'aws-ha-dr-lab',
            description: 'Project name'
        )

        string(
            name: 'ENVIRONMENT',
            defaultValue: 'dev',
            description: 'Environment name'
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
            defaultValue: 'main',
            description: 'Application repository branch'
        )

        string(
            name: 'APP_DOCKER_CONTEXT',
            defaultValue: '.',
            description: 'Docker build context'
        )
    }

    environment {

        /*
         * Windows executable paths.
         *
         * Preferred Terraform location:
         * C:\Terraform\terraform.exe
         *
         * AWS CLI location shown below is your current installation.
         */
        TERRAFORM_EXE = 'C:\\Terraform\\terraform.exe'

        AWS_EXE = 'C:\\Users\\DELL\\AppData\\Local\\Programs\\Amazon\\AWSCLIV2\\aws.exe'

        AWS_REGION = "${params.AWS_REGION}"

        AWS_DEFAULT_REGION = "${params.AWS_REGION}"

        ECR_REGISTRY = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_REGION}.amazonaws.com"

        ECR_REPOSITORY = "${params.PROJECT_NAME}-${params.ENVIRONMENT}-app"

        IMAGE_URI = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_REGION}.amazonaws.com/${params.PROJECT_NAME}-${params.ENVIRONMENT}-app:${env.BUILD_NUMBER}"

        AWS_CREDENTIALS_ID = 'aws-ha-dr-aws-credentials'

        TF_IN_AUTOMATION = 'true'

        TF_INPUT = 'false'

        /*
         * Network-only deployment directory.
         * Change this if your folder is named differently.
         */
        TF_NETWORK_DIR = 'network'
    }

    stages {

        stage('Checkout Infrastructure') {
            steps {
                echo 'Checking out infrastructure repository...'

                checkout scm
            }
        }

        stage('Validate Inputs and Tools') {
            steps {
                bat '''
                    @echo off

                    echo ==========================================
                    echo Checking Terraform executable
                    echo ==========================================

                    if not exist "%TERRAFORM_EXE%" (
                        echo ERROR: Terraform was not found:
                        echo %TERRAFORM_EXE%
                        exit /b 1
                    )

                    "%TERRAFORM_EXE%" version

                    echo.
                    echo ==========================================
                    echo Checking AWS CLI executable
                    echo ==========================================

                    if not exist "%AWS_EXE%" (
                        echo ERROR: AWS CLI was not found:
                        echo %AWS_EXE%
                        exit /b 1
                    )

                    "%AWS_EXE%" --version

                    echo.
                    echo ==========================================
                    echo Checking Git
                    echo ==========================================

                    git --version
                '''
            }
        }

        stage('Validate Required Directories') {
            steps {
                bat '''
                    @echo off

                    echo ==========================================
                    echo Checking Terraform directory
                    echo ==========================================

                    if not exist "%TF_NETWORK_DIR%" (
                        echo ERROR: Terraform directory was not found:
                        echo %TF_NETWORK_DIR%
                        exit /b 1
                    )

                    echo Terraform directory found:
                    echo %TF_NETWORK_DIR%
                '''
            }
        }

      /*  stage('Terraform Format Check') {
            steps {
                bat '''
                    @echo off

                    echo ==========================================
                    echo Terraform Format Check
                    echo ==========================================

                    "%TERRAFORM_EXE%" fmt -check -recursive
                '''
            }
        }
*/
        stage('Terraform Network Validation') {
            steps {
                dir("${TF_NETWORK_DIR}") {
                    bat '''
                        @echo off

                        echo ==========================================
                        echo Terraform Network Initialization
                        echo ==========================================

                        "%TERRAFORM_EXE%" init ^
                            -backend=false ^
                            -input=false

                        if errorlevel 1 (
                            echo ERROR: Terraform init failed.
                            exit /b 1
                        )

                        echo.
                        echo ==========================================
                        echo Terraform Network Validation
                        echo ==========================================

                        "%TERRAFORM_EXE%" validate

                        if errorlevel 1 (
                            echo ERROR: Terraform validation failed.
                            exit /b 1
                        )
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
                    bat '''
                        @echo off

                        echo ==========================================
                        echo AWS Caller Identity
                        echo ==========================================

                        "%AWS_EXE%" sts get-caller-identity ^
                            --region "%AWS_REGION%"

                        if errorlevel 1 (
                            echo ERROR: AWS authentication failed.
                            exit /b 1
                        )
                    '''
                }
            }
        }

        stage('Network Terraform Plan') {
            steps {
                tfDeploy("${env.TF_NETWORK_DIR}", '')
            }
        }

        stage('Network Terraform Apply') {
            when {
                expression {
                    return params.DEPLOY_INFRASTRUCTURE
                }
            }

            steps {
                dir("${env.TF_NETWORK_DIR}") {
                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {
                        bat '''
                            @echo off

                            echo ==========================================
                            echo Terraform Network Apply
                            echo ==========================================

                            if not exist tfplan (
                                echo ERROR: tfplan file was not found.
                                exit /b 1
                            )

                            "%TERRAFORM_EXE%" apply ^
                                -input=false ^
                                -auto-approve ^
                                tfplan

                            if errorlevel 1 (
                                echo ERROR: Terraform apply failed.
                                exit /b 1
                            )
                        '''
                    }
                }
            }
        }

        /*
        ============================================================
        TEMPORARILY DISABLED STAGES
        Enable these after Network deployment is successful.
        ============================================================

        stage('Checkout Application') {
            when {
                expression {
                    return params.APP_REPOSITORY_URL?.trim()
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
                                script: '''
                                    @echo off
                                    "%AWS_EXE%" ssm get-parameter ^
                                        --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 ^
                                        --query Parameter.Value ^
                                        --output text ^
                                        --region "%AWS_REGION%"
                                ''',
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
                            @echo off

                            if not exist Dockerfile (
                                echo ERROR: Dockerfile was not found.
                                exit /b 1
                            )

                            "%AWS_EXE%" ecr describe-repositories ^
                                --repository-names "%ECR_REPOSITORY%" ^
                                --region "%AWS_REGION%"

                            if errorlevel 1 (
                                echo ECR repository was not found. Creating it...

                                "%AWS_EXE%" ecr create-repository ^
                                    --repository-name "%ECR_REPOSITORY%" ^
                                    --region "%AWS_REGION%"

                                if errorlevel 1 (
                                    echo ERROR: ECR repository creation failed.
                                    exit /b 1
                                )
                            )

                            "%AWS_EXE%" ecr get-login-password ^
                                --region "%AWS_REGION%" |
                                docker login ^
                                --username AWS ^
                                --password-stdin "%ECR_REGISTRY%"

                            if errorlevel 1 (
                                echo ERROR: Docker login failed.
                                exit /b 1
                            )

                            docker build ^
                                -t "%IMAGE_URI%" ^
                                "%APP_DOCKER_CONTEXT%"

                            if errorlevel 1 (
                                echo ERROR: Docker build failed.
                                exit /b 1
                            )

                            docker push "%IMAGE_URI%"

                            if errorlevel 1 (
                                echo ERROR: Docker push failed.
                                exit /b 1
                            )
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
                    return params.DOMAIN_NAME?.trim()
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

        success {
            echo '=========================================='
            echo 'Jenkins pipeline completed successfully.'
            echo '=========================================='
        }

        failure {
            echo '=========================================='
            echo 'Jenkins pipeline failed.'
            echo 'Please review the console output.'
            echo '=========================================='
        }

        always {
            echo 'Cleaning Jenkins workspace...'

            deleteDir()
        }
    }
}


/*
============================================================
Reusable Terraform deployment function
============================================================
*/

def tfDeploy(String module, String extraVars) {

    dir(module) {

        withCredentials([
            [
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: env.AWS_CREDENTIALS_ID
            ]
        ]) {

            bat """
                @echo off

                echo ==========================================
                echo Terraform Init - ${module}
                echo ==========================================

                "%TERRAFORM_EXE%" init ^
                    -input=false

                if errorlevel 1 (
                    echo ERROR: Terraform init failed for ${module}.
                    exit /b 1
                )

                echo.
                echo ==========================================
                echo Terraform Plan - ${module}
                echo ==========================================

                "%TERRAFORM_EXE%" plan ^
                    -input=false ^
                    -out=tfplan ^
                    ${extraVars}

                if errorlevel 1 (
                    echo ERROR: Terraform plan failed for ${module}.
                    exit /b 1
                )
            """

            if (params.DEPLOY_INFRASTRUCTURE) {
                bat """
                    @echo off

                    echo ==========================================
                    echo Terraform Apply - ${module}
                    echo ==========================================

                    "%TERRAFORM_EXE%" apply ^
                        -input=false ^
                        -auto-approve ^
                        tfplan

                    if errorlevel 1 (
                        echo ERROR: Terraform apply failed for ${module}.
                        exit /b 1
                    )
                """
            }
        }
    }
}
