pipeline {
    agent any

    parameters {

        // ================= VISUAL SECTION =================
        text(name: 'PRODUCT_SECTION',
             defaultValue: '================ PRODUCT DETAILS ================',
             description: ' ')

        string(name: 'PRODUCT_NAME', defaultValue: 'acer', description: 'Product name')
        string(name: 'CATEGORY', defaultValue: 'laptop', description: 'Category')
        string(name: 'PRICE', defaultValue: '30', description: 'Price')
        string(name: 'STOCK', defaultValue: '1', description: 'Stock')

        text(name: 'BUYER_SECTION',
             defaultValue: '================ BUYER DETAILS ================',
             description: ' ')

        string(name: 'BUYER_NAME', defaultValue: 'manoj', description: 'Buyer name')
        string(name: 'EMAIL', defaultValue: 'mk458557', description: 'Email')
        string(name: 'PHONE', defaultValue: '9000000003', description: 'Phone')
        string(name: 'ADDRESS', defaultValue: 'vip colony', description: 'Address')
    }

    stages {

        stage('Install Dependencies') {
            steps {
                sh 'pip3 install requests --break-system-packages'
            }
        }
        stage('Run Automation Script') {
            steps {
                sh 'python3 order2.py'
            }
        }
    }

    post {
        success {
            echo ' Build completed successfully'
        }
        failure {
            echo ' Build failed. Check logs.'
        }
    }
}
