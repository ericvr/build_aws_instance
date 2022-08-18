def genaralvars () {

    env.GIT_REPO = 'https://gitlab.com/tripetto/examples/angular.git'
    env.GIT_BRANCH = 'main'
    env.DOCKER_REPO = 'eeric466'
    CONTAINER_PORT= '82'

}

pipeline {
    agent any
    tools {
       terraform 'terraform20803'
    }
    
    stages {
        stage ("Set Variables") {
            steps {
                genaralvars()
            }
        }
        stage('Git checkout') {
           steps{
                git branch: 'main', url: 'https://github.com/ericvr/build_aws_instance.git'
            }
        }
        stage('terraform format check') {
            steps{
                sh 'terraform fmt'
            }
        }
        stage('terraform Init') {
            steps{
                sh 'terraform init'
            }
        }
        stage('terraform apply') {
            steps{
                //withAWS(credentials: 'aws-gonzafirma', region: 'us-east-1') {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'erick_aws_credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]){
                    sh "terraform apply --auto-approve"
                }
                script {
                    PUBLIC_IP_EC2 = sh (script: "terraform output instance_public_ip", returnStdout:true).trim()
                }
                echo "${PUBLIC_IP_EC2}"
            }
        }
        
        stage('Change inventory content') {
            steps{
                sh "echo $PUBLIC_IP_EC2 > inventory.hosts"
            }
        } 
        stage('Wait 5 minutes') {
            steps {
                sleep time:5, unit: 'MINUTES'
            }
        }
        
        stage ("Install docker in aws") {
            steps {
                ansiblePlaybook become: true, colorized: true, extras: '-v', disableHostKeyChecking: true, credentialsId: 'erick-ssh', installation: 'ansible210', inventory: 'inventory.hosts', playbook: 'playbook-install-docker-2option.yml'
            }
        }
        
        stage ("Verify If exist container") {
            steps {
                    script {
                        DOCKERID = sh (script: "docker ps -f publish=${CONTAINER_PORT} -q", returnStdout: true).trim()
                        if  ( DOCKERID !="" ) {
                            if (fileExists('terraform.tfstate')) {
                                sh "terraform destroy  -var=\"container_port=${CONTAINER_PORT}\" -var=\"reponame=${env.DOCKER_REPO}\" --target docker_container.nginx --auto-approve"
                            }
                            else {
                                sh "docker stop ${DOCKERID}"
                            }
                        }
                }
            }
        }
        
    }
} 