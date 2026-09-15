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
            description: 'AMI ID for application deployment'
        )

        string(
            name: 'NOTIFICATION_EMAIL',
            defaultValue: '',
            description: 'Notification email'
        )

        string(
            name: 'DOMAIN_NAME',
            defaultValue: '',
            description: 'Domain name'
        )

        string(
            name: 'APP_REPOSITORY_URL',
            defaultValue: '',
            description: 'Application repository URL'
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

        TF_DATABASE_DIR = 'database'
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

        stage('Validate Database Directory') {

            steps {

                bat '''
                    @echo off

                    echo ==========================================
                    echo Checking Database Terraform directory
                    echo ==========================================

                    if not exist "%TF_DATABASE_DIR%" (
                        echo ERROR: Database Terraform directory was not found:
                        echo %TF_DATABASE_DIR%
                        exit /b 1
                    )

                    echo Database Terraform directory found:
                    echo %TF_DATABASE_DIR%
                '''
            }
        }

        stage('Terraform Database Validation') {

            steps {

                dir("${env.TF_DATABASE_DIR}") {

                    bat '''
                        @echo off

                        echo ==========================================
                        echo Terraform Database Initialization
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
                        echo Terraform Database Validation
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

        stage('Database Terraform Plan and Apply') {

            steps {

                tfDeploy(
                    "${env.TF_DATABASE_DIR}",
                    ''
                )
            }
        }
    }

    post {

        success {

            echo '=========================================='

            echo 'Database Terraform pipeline completed successfully.'

            echo '=========================================='
        }

        failure {

            echo '=========================================='

            echo 'Database Terraform pipeline failed.'

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

                    if not exist tfplan (
                        echo ERROR: tfplan file was not found.
                        exit /b 1
                    )

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
