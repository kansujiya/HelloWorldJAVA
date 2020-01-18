pipeline
{
    agent any
	tools
	{
		maven 'Maven'
	}
	options
    {
        // Append time stamp to the console output.
        timestamps()
      
        timeout(time: 1, unit: 'HOURS')
      
        // Do not automatically checkout the SCM on every stage. We stash what
        // we need to save time.
        skipDefaultCheckout()
      
        // Discard old builds after 10 days or 30 builds count.
        buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10'))
	  
	    //To avoid concurrent builds to avoid multiple checkouts
	    disableConcurrentBuilds()
    }
    stages
    {
	    stage ('checkout')
		{
			steps
			{
				checkout scm
			}
		}
		stage ('Build')
		{
			steps
			{
				sh "mvn install"
			}
		}
		stage ('Unit Testing')
		{
			steps
			{
				sh "mvn test"
			}
		}
		stage ('Sonar Analysis')
		{
			steps
			{
				withSonarQubeEnv("Test_Sonar") 
				{
					sh "mvn sonar:sonar"
				}
			}
		}
		stage ('Upload to Artifactory')
		{
			steps
			{
				rtMavenDeployer (
                    id: 'deployer',
                    serverId: '123456789@artifactory',
                    releaseRepo: 'sureshkansujiya',
                    snapshotRepo: 'sureshkansujiya'
                )
                rtMavenRun (
                    pom: 'pom.xml',
                    goals: 'clean install',
                    deployerId: 'deployer',
                )
                rtPublishBuildInfo (
                    serverId: '123456789@artifactory',
                )
			}
		}
		stage ('Docker Image')
		{
			steps
			{
				sh returnStdout: true, script: '/bin/docker build -t dtr.nagarro.com:443/devopssampleapplication_sureshkansujiya:${BUILD_NUMBER} -f Dockerfile .'
			}
		}
		stage ('Push to DTR')
	    {
		    steps
		    {
		    	sh returnStdout: true, script: '/bin/docker push dtr.nagarro.com:443/devopssampleapplication_sureshkansujiya:${BUILD_NUMBER}'
		    }
	    }
        stage ('Stop Running container')
    	{
	        steps
	        {
	            sh '''
                    ContainerID=$(docker ps | grep 7015 | cut -d " " -f 1)
                    if [  $ContainerID ]
                    then
                        docker stop $ContainerID
                        docker rm -f $ContainerID
                    fi
                '''
	        }
	    }

		stage ('Docker deployment')
		{
		    steps
		    {
		        sh 'docker run --name devopssampleapplication_charugarg -d -p 7016:8080 dtr.nagarro.com:443/devopssampleapplication_charugarg:${BUILD_NUMBER}'
		    }
		}
	}
	post 
	{
        always 
		{
			emailext attachmentsPattern: 'report.html', body: '${JELLY_SCRIPT,template="health"}', mimeType: 'text/html', recipientProviders: [[$class: 'RequesterRecipientProvider']], replyTo: 'charu.garg@nagarro.com', subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: 'charu.garg@nagarro.com'
        }
    }
}
