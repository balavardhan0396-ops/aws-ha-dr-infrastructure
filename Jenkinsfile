pipeline {

    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    parameters {

        string(
            name: 'AWS_ACCOUNT_ID',
            defaultValue: 'YOUR_AWS_ACCOUNT_ID',
            description: 'AWS Account ID'
        )

        choice(
            name: 'AWS_REGION',
            choices: [
                'us-east-1',
                'us-east-2',
                'us-west-1',
                'us-west-2'
            ],
            description: 'AWS Region'
        )

        string(
            name: 'PROJECT_NAME',
            defaultValue: 'aws-ha-dr',
            description: 'Project name'
        )

        choice(
            name: 'ENVIRONMENT',
            choices: [
                'dev',
                'test',
                'prod'
            ],
            description: 'Environment name'
        )

        booleanParam(
            name: 'DEPLOY_INFRASTRUCTURE',
            defaultValue: false,
            description: 'Set true only after reviewing the Terraform plan'
        )
    }

    environment {

        TERRAFORM_EXE = 'C:\\Terraform\\terraform.exe'
        AWS_EXE        = 'C:\\Program Files\\Amazon\\AWSCLIV2\\aws.exe'

        AWS_REGION = "${params.AWS_REGION}"
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"

        AWS_CREDENTIALS_ID = 'aws-ha-dr-aws-credentials'

        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'

        /*
         * Terraform module directories
         */
        TF_NETWORK_DIR     = 'network'
        TF_SECURITY_DIR    = 'security'
        TF_DATABASE_DIR    = 'database'
        TF_APPLICATION_DIR = 'application'
        TF_DNS_DIR         = 'dns-https'
        TF_MONITORING_DIR  = 'monitoring'
        TF_SCRIPTS_DIR     = 'scripts'
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

        /*
         * ==========================================================
         * NETWORK MODULE
         * ==========================================================
         *
         * Network is already completed.
         *
         * Keep this section commented for now.
         * Remove the comments when Network needs to be deployed
         * or updated in the future.
         */

        /*
        stage('Validate Network Directory') {

            steps {

                bat '''
                    @echo off

                    if not exist "%TF_NETWORK_DIR%" (
                        echo ERROR: Network directory was not found.
                        exit /b 1
                    )

                    echo Network directory found:
                    echo %TF_NETWORK_DIR%
                '''
            }
        }

        stage('Network Terraform Init and Validate') {

            steps {

                dir("${env.TF_NETWORK_DIR}") {

                    bat '''
                        @echo off

                        "%TERRAFORM_EXE%" init -input=false

                        if errorlevel 1 (
                            echo ERROR: Network Terraform init failed.
                            exit /b 1
                        )

                        "%TERRAFORM_EXE%" validate

                        if errorlevel 1 (
                            echo ERROR: Network Terraform validation failed.
                            exit /b 1
                        )
                    '''
                }
            }
        }

        stage('Network Terraform Plan') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_NETWORK_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" plan ^
                                -input=false ^
                                -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Network Terraform Apply') {

            when {
                expression {
                    return params.DEPLOY_INFRASTRUCTURE
                }
            }

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_NETWORK_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" apply ^
                                -input=false ^
                                -auto-approve ^
                                tfplan
                        '''
                    }
                }
            }
        }
        */

        /*
         * ==========================================================
         * SECURITY MODULE - ACTIVE
         * ==========================================================
         */

        stage('Validate Security Directory') {

            steps {

                bat '''
                    @echo off

                    echo ==========================================
                    echo Checking Security Terraform directory
                    echo ==========================================

                    if not exist "%TF_SECURITY_DIR%" (
                        echo ERROR: Security Terraform directory was not found:
                        echo %TF_SECURITY_DIR%
                        exit /b 1
                    )

                    echo Security Terraform directory found:
                    echo %TF_SECURITY_DIR%
                '''
            }
        }

        stage('Security Terraform Init and Validate') {

            steps {

                dir("${env.TF_SECURITY_DIR}") {

                    bat '''
                        @echo off

                        echo ==========================================
                        echo Security Terraform Initialization
                        echo ==========================================

                        "%TERRAFORM_EXE%" init -input=false

                        if errorlevel 1 (
                            echo ERROR: Security Terraform init failed.
                            exit /b 1
                        )

                        echo.
                        echo ==========================================
                        echo Security Terraform Validation
                        echo ==========================================

                        "%TERRAFORM_EXE%" validate

                        if errorlevel 1 (
                            echo ERROR: Security Terraform validation failed.
                            exit /b 1
                        )
                    '''
                }
            }
        }

        stage('Security Terraform Plan') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_SECURITY_DIR}") {

                        bat '''
                            @echo off

                            echo ==========================================
                            echo Security Terraform Plan
                            echo ==========================================

                            "%TERRAFORM_EXE%" plan ^
                                -input=false ^
                                -out=tfplan

                            if errorlevel 1 (
                                echo ERROR: Security Terraform plan failed.
                                exit /b 1
                            )
                        '''
                    }
                }
            }
        }

        stage('Security Terraform Apply') {

            when {
                expression {
                    return params.DEPLOY_INFRASTRUCTURE
                }
            }

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_SECURITY_DIR}") {

                        bat '''
                            @echo off

                            echo ==========================================
                            echo Security Terraform Apply
                            echo ==========================================

                            "%TERRAFORM_EXE%" apply ^
                                -input=false ^
                                -auto-approve ^
                                tfplan

                            if errorlevel 1 (
                                echo ERROR: Security Terraform apply failed.
                                exit /b 1
                            )
                        '''
                    }
                }
            }
        }

        /*
         * ==========================================================
         * DATABASE MODULE
         * ==========================================================
         *
         * Database is already completed.
         *
         * Keep commented for now.
         */

        /*
        stage('Validate Database Directory') {

            steps {

                bat '''
                    @echo off

                    if not exist "%TF_DATABASE_DIR%" (
                        echo ERROR: Database directory was not found.
                        exit /b 1
                    )

                    echo Database directory found:
                    echo %TF_DATABASE_DIR%
                '''
            }
        }

        stage('Database Terraform Init and Validate') {

            steps {

                dir("${env.TF_DATABASE_DIR}") {

                    bat '''
                        @echo off

                        "%TERRAFORM_EXE%" init -input=false

                        if errorlevel 1 exit /b 1

                        "%TERRAFORM_EXE%" validate

                        if errorlevel 1 exit /b 1
                    '''
                }
            }
        }

        stage('Database Terraform Plan') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_DATABASE_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" plan ^
                                -input=false ^
                                -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Database Terraform Apply') {

            when {
                expression {
                    return params.DEPLOY_INFRASTRUCTURE
                }
            }

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_DATABASE_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" apply ^
                                -input=false ^
                                -auto-approve ^
                                tfplan
                        '''
                    }
                }
            }
        }
        */

        /*
         * ==========================================================
         * APPLICATION MODULE - FUTURE
         * ==========================================================
         *
         * Uncomment this complete block when Application deployment
         * is required.
         */

        /*
        stage('Application Terraform Init and Validate') {

            steps {

                dir("${env.TF_APPLICATION_DIR}") {

                    bat '''
                        @echo off

                        "%TERRAFORM_EXE%" init -input=false

                        if errorlevel 1 exit /b 1

                        "%TERRAFORM_EXE%" validate

                        if errorlevel 1 exit /b 1
                    '''
                }
            }
        }

        stage('Application Terraform Plan') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_APPLICATION_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" plan ^
                                -input=false ^
                                -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Application Terraform Apply') {

            when {
                expression {
                    return params.DEPLOY_INFRASTRUCTURE
                }
            }

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_APPLICATION_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" apply ^
                                -input=false ^
                                -auto-approve ^
                                tfplan
                        '''
                    }
                }
            }
        }
        */

        /*
         * ==========================================================
         * DNS / HTTPS / CLOUDFRONT MODULE - FUTURE
         * ==========================================================
         */

        /*
        stage('DNS HTTPS Terraform Init and Validate') {

            steps {

                dir("${env.TF_DNS_DIR}") {

                    bat '''
                        @echo off

                        "%TERRAFORM_EXE%" init -input=false

                        if errorlevel 1 exit /b 1

                        "%TERRAFORM_EXE%" validate

                        if errorlevel 1 exit /b 1
                    '''
                }
            }
        }

        stage('DNS HTTPS Terraform Plan') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_DNS_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" plan ^
                                -input=false ^
                                -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('DNS HTTPS Terraform Apply') {

            when {
                expression {
                    return params.DEPLOY_INFRASTRUCTURE
                }
            }

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_DNS_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" apply ^
                                -input=false ^
                                -auto-approve ^
                                tfplan
                        '''
                    }
                }
            }
        }
        */

        /*
         * ==========================================================
         * MONITORING MODULE - FUTURE
         * ==========================================================
         */

        /*
        stage('Monitoring Terraform Init and Validate') {

            steps {

                dir("${env.TF_MONITORING_DIR}") {

                    bat '''
                        @echo off

                        "%TERRAFORM_EXE%" init -input=false

                        if errorlevel 1 exit /b 1

                        "%TERRAFORM_EXE%" validate

                        if errorlevel 1 exit /b 1
                    '''
                }
            }
        }

        stage('Monitoring Terraform Plan') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_MONITORING_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" plan ^
                                -input=false ^
                                -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Monitoring Terraform Apply') {

            when {
                expression {
                    return params.DEPLOY_INFRASTRUCTURE
                }
            }

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_MONITORING_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" apply ^
                                -input=false ^
                                -auto-approve ^
                                tfplan
                        '''
                    }
                }
            }
        }
        */

        /*
         * ==========================================================
         * SCRIPTS MODULE - FUTURE
         * ==========================================================
         */

        /*
        stage('Run Deployment and Validation Scripts') {

            steps {

                dir("${env.TF_SCRIPTS_DIR}") {

                    bat '''
                        @echo off

                        echo Running deployment and validation scripts...

                        rem Add script commands here later.
                        rem Example:
                        rem powershell -ExecutionPolicy Bypass -File deploy.ps1
                    '''
                }
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
