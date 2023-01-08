pipeline{
    agent any
    stages{
        stage("Delete the workspace after build done"){
            steps{
                cleanWs()
            }
        }
        stage("SCM"){
            steps{
                checkout([$class: 'GitSCM', 
			        branches: [[name: '*/master']], 
			        extensions: [], 
			        userRemoteConfigs: [[credentialsId: 'github', 
			        url: 'https://github.com/kishorenagisetty/Java_project.git']]])
            }
        }
        stage("Build"){
            steps{
                script{
                    sh "/opt/maven/bin/mvn clean install" 
                }  
            }
        }
        stage("Copying Artifacts from jenkins to target server"){
            steps{
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'deployment_server', 
                            transfers: [sshTransfer(
				            execTimeout: 120000, 
				            remoteDirectory: '', 
				            removePrefix: '/webapp/target/', 
				            sourceFiles: '**/*.war')])])
            }
        }
    }
    post{
        always{
            emailext body: '',
            to: 'kishore.nagisetty@outlook.com',
            subject: ''
        }
    }
}