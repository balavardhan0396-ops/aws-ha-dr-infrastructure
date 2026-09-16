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

        AWS_EXE = 'C:\\Users\\DELL\\AppData\\Local\\Programs\\Amazon\\AWSCLIV2\\aws.exe'

        AWS_REGION = "${params.AWS_REGION}"
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"

        // Newly created Jenkins AWS credential ID
        AWS_CREDENTIALS_ID = 'aws-login-crds'

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

        stage('Test AWS Credentials') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    bat '''
                        @echo off

                        echo ==========================================
                        echo Testing AWS Credentials
                        echo ==========================================

                        "%AWS_EXE%" sts get-caller-identity

                        if errorlevel 1 (
                            echo ERROR: AWS credentials validation failed.
                            exit /b 1
                        )

                        echo AWS credentials are working successfully.
                    '''
                }
            }
        }

        /*
         * ==========================================================
         * SECURITY MODULE - ACTIVE
         * ==========================================================
         */

/*        stage('Validate Security Directory') {

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

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_SECURITY_DIR}") {

                        bat '''
                            @echo off

                            echo ==========================================
                            echo Security Terraform Initialization
                            echo ==========================================

                            "%TERRAFORM_EXE%" init -input=false -reconfigure

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

                            echo Security Terraform init and validation completed.
                        '''
                    }
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

                            echo Security Terraform plan completed.
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

                            echo Security Terraform apply completed.
                        '''
                    }
                }
            }
        }   */

        /*
         * ==========================================================
         * NETWORK MODULE - CURRENTLY DISABLED
         * ==========================================================
         *
         * Network is already completed.
         * Uncomment this section only when required.
         */

        /*
        stage('Network Terraform Init and Validate') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_NETWORK_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" init -input=false -reconfigure

                            if errorlevel 1 exit /b 1

                            "%TERRAFORM_EXE%" validate

                            if errorlevel 1 exit /b 1
                        '''
                    }
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

                            if errorlevel 1 exit /b 1
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

                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }
        */

        /*
         * ==========================================================
         * DATABASE MODULE - CURRENTLY DISABLED
         * ==========================================================
         */

        /*
        stage('Database Terraform Init and Validate') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_DATABASE_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" init -input=false -reconfigure

                            if errorlevel 1 exit /b 1

                            "%TERRAFORM_EXE%" validate

                            if errorlevel 1 exit /b 1
                        '''
                    }
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

                            if errorlevel 1 exit /b 1
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

                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }
        */

        /*
         * ==========================================================
         * APPLICATION MODULE 
         * ==========================================================
         */

        
    /*    stage('Application Terraform Init and Validate') {

            steps {

                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {

                    dir("${env.TF_APPLICATION_DIR}") {

                        bat '''
                            @echo off

                            "%TERRAFORM_EXE%" init -input=false -reconfigure

                            if errorlevel 1 exit /b 1

                            "%TERRAFORM_EXE%" validate

                            if errorlevel 1 exit /b 1
                        '''
                    }
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

                            if errorlevel 1 exit /b 1
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

                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }
        

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
*/
        /*
 * ==========================================================
 * DNS-HTTPS MODULE
 * ==========================================================
 */

stage('DNS-HTTPS Terraform Init and Validate') {

    steps {

        withCredentials([
            [$class: 'AmazonWebServicesCredentialsBinding',
             credentialsId: "${env.AWS_CREDENTIALS_ID}"]
        ]) {

            dir("${env.TF_DNS_DIR}") {

                bat '''
                    @echo off

                    echo ==========================================
                    echo DNS-HTTPS Terraform Initialization
                    echo ==========================================

                    "%TERRAFORM_EXE%" init -input=false -reconfigure

                    if errorlevel 1 (
                        echo ERROR: DNS-HTTPS Terraform init failed.
                        exit /b 1
                    )

                    echo.
                    echo ==========================================
                    echo DNS-HTTPS Terraform Validation
                    echo ==========================================

                    "%TERRAFORM_EXE%" validate

                    if errorlevel 1 (
                        echo ERROR: DNS-HTTPS Terraform validation failed.
                        exit /b 1
                    )

                    echo DNS-HTTPS Terraform init and validation completed.
                '''
            }
        }
    }
}

stage('DNS-HTTPS Terraform Plan') {

    steps {

        withCredentials([
            [$class: 'AmazonWebServicesCredentialsBinding',
             credentialsId: "${env.AWS_CREDENTIALS_ID}"]
        ]) {

            dir("${env.TF_DNS_DIR}") {

                bat '''
                    @echo off

                    echo ==========================================
                    echo DNS-HTTPS Terraform Plan
                    echo ==========================================

                    "%TERRAFORM_EXE%" plan ^
                        -input=false ^
                        -out=tfplan

                    if errorlevel 1 (
                        echo ERROR: DNS-HTTPS Terraform plan failed.
                        exit /b 1
                    )

                    echo DNS-HTTPS Terraform plan completed.
                '''
            }
        }
    }
}

stage('DNS-HTTPS Terraform Apply') {

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

                    echo ==========================================
                    echo DNS-HTTPS Terraform Apply
                    echo ==========================================

                    "%TERRAFORM_EXE%" apply ^
                        -input=false ^
                        -auto-approve ^
                        tfplan

                    if errorlevel 1 (
                        echo ERROR: DNS-HTTPS Terraform apply failed.
                        exit /b 1
                    )

                    echo DNS-HTTPS Terraform apply completed.
                '''
            }
        }
    }
}
