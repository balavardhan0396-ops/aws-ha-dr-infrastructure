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
                'eu-north-1',
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
            description: 'Set true only after reviewing Terraform plan'
        )
    }

    environment {

        TERRAFORM_EXE = 'C:\\Terraform\\terraform.exe'

        AWS_EXE = 'C:\\Users\\DELL\\AppData\\Local\\Programs\\Amazon\\AWSCLIV2\\aws.exe'

        AWS_REGION = "${params.AWS_REGION}"
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"

        AWS_CREDENTIALS_ID = 'aws-login-crds'

        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'

        TF_NETWORK_DIR = 'network'
        TF_SECURITY_DIR = 'security'
        TF_DATABASE_DIR = 'database'
        TF_APPLICATION_DIR = 'application'
        TF_DNS_DIR = 'dns-https'
        TF_MONITORING_DIR = 'monitoring'
        TF_SCRIPTS_DIR = 'scripts'
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

                    if not exist "%TERRAFORM_EXE%" (
                        echo ERROR: Terraform was not found.
                        exit /b 1
                    )

                    "%TERRAFORM_EXE%" version

                    if not exist "%AWS_EXE%" (
                        echo ERROR: AWS CLI was not found.
                        exit /b 1
                    )

                    "%AWS_EXE%" --version

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
                        "%AWS_EXE%" sts get-caller-identity

                        if errorlevel 1 (
                            echo ERROR: AWS credentials validation failed.
                            exit /b 1
                        )
                    '''
                }
            }
        }


        /*
        ============================================================
        SECURITY MODULE - COMMENTED
        Remove the opening and closing comment markers to enable
        ============================================================

        stage('Security Terraform Init and Validate') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {
                    dir("${env.TF_SECURITY_DIR}") {
                        bat '''
                            "%TERRAFORM_EXE%" init -input=false -reconfigure
                            if errorlevel 1 exit /b 1

                            "%TERRAFORM_EXE%" validate
                            if errorlevel 1 exit /b 1
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
                            "%TERRAFORM_EXE%" plan -input=false -out=tfplan
                            if errorlevel 1 exit /b 1
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
                            "%TERRAFORM_EXE%" apply -input=false -auto-approve tfplan
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }

        */


        /*
        ============================================================
        NETWORK MODULE - COMMENTED
        ============================================================

        stage('Network Terraform Init and Validate') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {
                    dir("${env.TF_NETWORK_DIR}") {
                        bat '''
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
                            "%TERRAFORM_EXE%" plan -input=false -out=tfplan
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
                            "%TERRAFORM_EXE%" apply -input=false -auto-approve tfplan
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }

        */


        /*
        ============================================================
        DATABASE MODULE - COMMENTED
        ============================================================

        stage('Database Terraform Init and Validate') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {
                    dir("${env.TF_DATABASE_DIR}") {
                        bat '''
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
                            "%TERRAFORM_EXE%" plan -input=false -out=tfplan
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
                            "%TERRAFORM_EXE%" apply -input=false -auto-approve tfplan
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }

        */


        /*
        ============================================================
        APPLICATION MODULE - COMMENTED
        ============================================================

        stage('Application Terraform Init and Validate') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {
                    dir("${env.TF_APPLICATION_DIR}") {
                        bat '''
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
                            "%TERRAFORM_EXE%" plan -input=false -out=tfplan
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
                            "%TERRAFORM_EXE%" apply -input=false -auto-approve tfplan
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }

        */


        /*
        ============================================================
        MONITORING MODULE - COMMENTED
        ============================================================

        stage('Monitoring Terraform Init and Validate') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {
                    dir("${env.TF_MONITORING_DIR}") {
                        bat '''
                            "%TERRAFORM_EXE%" init -input=false -reconfigure
                            if errorlevel 1 exit /b 1

                            "%TERRAFORM_EXE%" validate
                            if errorlevel 1 exit /b 1
                        '''
                    }
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
                            "%TERRAFORM_EXE%" plan -input=false -out=tfplan
                            if errorlevel 1 exit /b 1
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
                            "%TERRAFORM_EXE%" apply -input=false -auto-approve tfplan
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }

        */


        /*
        ============================================================
        SCRIPTS MODULE - COMMENTED
        ============================================================

        stage('Scripts Terraform Init and Validate') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {
                    dir("${env.TF_SCRIPTS_DIR}") {
                        bat '''
                            "%TERRAFORM_EXE%" init -input=false -reconfigure
                            if errorlevel 1 exit /b 1

                            "%TERRAFORM_EXE%" validate
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }

        stage('Scripts Terraform Plan') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${env.AWS_CREDENTIALS_ID}"]
                ]) {
                    dir("${env.TF_SCRIPTS_DIR}") {
                        bat '''
                            "%TERRAFORM_EXE%" plan -input=false -out=tfplan
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }

        stage('Scripts Terraform Apply') {
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
                    dir("${env.TF_SCRIPTS_DIR}") {
                        bat '''
                            "%TERRAFORM_EXE%" apply -input=false -auto-approve tfplan
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }

        */


        /*
        ============================================================
        DNS-HTTPS MODULE - ACTIVE
        ============================================================
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

                            "%TERRAFORM_EXE%" init -input=false -reconfigure
                            if errorlevel 1 exit /b 1

                            "%TERRAFORM_EXE%" validate
                            if errorlevel 1 exit /b 1
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

                            "%TERRAFORM_EXE%" plan -input=false -out=tfplan
                            if errorlevel 1 exit /b 1
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

                            "%TERRAFORM_EXE%" apply -input=false -auto-approve tfplan
                            if errorlevel 1 exit /b 1
                        '''
                    }
                }
            }
        }
    }

    post {

        success {
            echo 'Jenkins pipeline completed successfully.'
        }

        failure {
            echo 'Jenkins pipeline failed. Please review the console output.'
        }

        always {
            echo 'Cleaning Jenkins workspace...'
            deleteDir()
        }
    }
}
