def genaralvars () {

    env.GIT_REPO = 'https://github.com/ericvr/build_aws_instance.git'
    env.GIT_BRANCH = 'main'
    env.DOCKER_REPO = 'eeric466'
    CONTAINER_PORT= '82'
    env.GIT_WEB = 'https://github.com/ericvr/ericvr.github.io.git'

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
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO}"
                sh "mkdir public"
            }
        }
        stage('Git web checkout  ') {
           steps{
                dir("public"){
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_WEB}"
                }
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
        stage('Wait 1 minute') {
            steps {
                sleep time:1, unit: 'MINUTES'
            }
        }
        
        stage ("Install docker in aws") {
            steps {
                ansiblePlaybook become: true, colorized: true, extras: '-v', disableHostKeyChecking: true, credentialsId: 'erick-ssh', installation: 'ansible210', inventory: 'inventory.hosts', playbook: 'playbook-install-docker-2option.yml'
            }
        }
        
        stage ("Create Dockerfile") {
            steps {
                sh '''
                    cat <<EOT > Dockerfile
                    FROM nginx:latest
                    COPY public/ /usr/share/nginx/html/
                '''
            }
        }
        stage ("Build Image") {
            steps {
                sh "docker build -t ${env.DOCKER_REPO}/${JOB_BASE_NAME}:${BUILD_NUMBER} ."
            }
        }
        stage ("Publish Image") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'erick-hub1', passwordVariable: 'docker_pass', usernameVariable: 'docker_user')]) {
                    sh "docker login -u $docker_user -p $docker_pass"
                    sh "docker push ${env.DOCKER_REPO}/${JOB_BASE_NAME}:${BUILD_NUMBER}"
                }
            }
        }
        stage ("Pull docker in aws") {
            steps {
                ansiblePlaybook become: true, colorized: true, extras: '-v', disableHostKeyChecking: true, credentialsId: 'erick-ssh', installation: 'ansible210', inventory: 'inventory.hosts', playbook: 'playbook-pull-docker.yml', extraVars: [ var_job_name: "${JOB_BASE_NAME}", var_build_number: "${BUILD_NUMBER}", var_docker_repo: "${env.DOCKER_REPO}", var_container_port: "${CONTAINER_PORT}", var_ip: "${PUBLIC_IP_EC2}" ]
            }
        }
        stage ("Run docker in aws") {
            steps {
                ansiblePlaybook become: true, colorized: true, extras: '-v', disableHostKeyChecking: true, credentialsId: 'erick-ssh', installation: 'ansible210', inventory: 'inventory.hosts', playbook: 'playbook-run-docker.yml', extraVars: [ var_job_name: "${JOB_BASE_NAME}", var_build_number: "${BUILD_NUMBER}", var_docker_repo: "${env.DOCKER_REPO}", var_container_port: "${CONTAINER_PORT}", var_ip: "${PUBLIC_IP_EC2}" ]
            }
        }
        stage('Manual Approval to Destroy the Infra') {
            steps{
                input "Proceed with destroy the Infra?"
            }
        }
        stage('Executing Terraform Destroy') {
            steps{
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'erick_aws_credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]){
                sh "terraform destroy --auto-approve"
            }
            }
        }
        
    }
}