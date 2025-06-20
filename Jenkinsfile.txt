pipeline { 
    agent any 
    environment { 
        dockerCreds = credentials('dockerhub_login') // used to get the username for next var 
        registry = "${dockerCreds_USR}/nodejs-webserver" 
        registryCredentials = "dockerhub_login" 
        dockerImage = "" // empty var, will be written to later 
    } 
    stages { 
        stage('Build Image') { 
            steps {
                dir('web') { 
                    script { 
                        dockerImage = docker.build(registry) 
                    } 
                }
            } 
        } 
        stage('Test App') {
            environment {
                SERVER_IMAGE = dockerImage.imageName()
            }
            steps {
                sh 'docker compose up -d'
                sh 'curl -s http://localhost/web1'
                sh 'curl -s http://localhost/web2'
                sh 'docker compose down'
            }
        }
        stage('Push Image') { 
            steps { 
                script { 
                    docker.withRegistry("", registryCredentials) { 
                        dockerImage.push("${env.BUILD_NUMBER}") 
                        dockerImage.push("latest") 
                    } 
                } 
            } 
        } 
        stage('Clean Up') { 
            steps { 
                sh "docker image prune --all --force --filter 'until=48h'" // ensure that we don't accrue too many out-of-date images 
            } 
        } 
        stage('Deploy To Cluster') { 
            steps { 
                sh 'cp -u /mnt/k3s/config config.yaml'
                sh 'cp -u nginx/nginx.conf terraform/nginx.conf'
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply --auto-approve --no-color -var config_path=${WORKSPACE}/config.yaml -var server_image=${registry}'
                    sh 'terraform output --no-color'
                }
            } 
        } 
    } 
} 