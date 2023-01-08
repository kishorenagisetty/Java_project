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
        // stage("Copying Artifacts from jenkins to target server"){
        //     steps{
        //         script{
        //             // sh "scp -o trictHostKeyChecking=no ${WORKSPACE}/webapp/target/*.war deploy@10.1.1.73:/opt/tomcat/webapps/"
        //             // sh "scp -o -StrictHostKeyChecking=no ${WORKSPACE}/webapp/target/*.war deploy@10.1.1.73:/opt/tomcat/webapps"
        //             sh """
        //                 scp -o StrictHostKeyChecking=no ${WORKSPACE}/webapp/target/*.war deploy@10.1.1.73:/home/deploy
        //                 ssh -o StrictHostKeyChecking=no deploy@10.1.1.73 'cp -r /home/deploy/*.war /opt/tomcat/webapps/'
        //              """
        //         }
        //     }
        // }
    //     stage('Deploy to Tomcat'){
    //         sshagent(['Tomcat-cred']) {
    //      sh """
    //        scp -o StrictHostKeyChecking=no ${WORKSPACE}/webapp/target/*.war deploy@10.1.1.73:/home/deploy
    //        ssh -o StrictHostKeyChecking=no deploy@10.1.1.73 'cp -r /home/deploy/*.war /opt/tomcat/webapps/'
    //      """
    //   }
    }
    post{
        always{
            emailext body: '',
            to: 'kishore.nagisetty@outlook.com, guruuklayan@gmail.com',
            subject: ''
        }
    }
}