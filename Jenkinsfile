pipeline {
    agent any

    parameters {

        //  PRODUCT DETAILS 
        string(name: 'PRODUCT_NAME', defaultValue: 'acer', description: 'Enter product name')
        string(name: 'CATEGORY', defaultValue: 'laptop', description: 'Enter category')
        string(name: 'PRICE', defaultValue: '30', description: 'Enter product price')
        string(name: 'STOCK', defaultValue: '1', description: 'Enter stock quantity')

        // BUYER DETAILS 
        string(name: 'BUYER_NAME', defaultValue: 'manoj', description: 'Enter buyer name')
        string(name: 'EMAIL', defaultValue: 'mk458557', description: 'Enter email')
        string(name: 'PHONE', defaultValue: '9000000003', description: 'Enter phone number')
        string(name: 'ADDRESS', defaultValue: 'vip colony', description: 'Enter address')
    }

    stages {

        stage('Install Dependencies') {
            steps {
                sh 'pip3 install requests --break-system-packages'
            }
        }

        stage('Run Automation Script') {
            steps {
                sh '''
                export PRODUCT_NAME="${PRODUCT_NAME}"
                export CATEGORY="${CATEGORY}"
                export PRICE="${PRICE}"
                export STOCK="${STOCK}"
                export BUYER_NAME="${BUYER_NAME}"
                export EMAIL="${EMAIL}"
                export PHONE="${PHONE}"
                export ADDRESS="${ADDRESS}"

                python3 order2.py
                '''
            }
        }
    }

    post {
        success {
            echo 'Build completed successfully '
        }
        failure {
            echo 'Build failed  Check logs'
        }
    }
}
