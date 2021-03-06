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
                    releaseRepo: 'sureshkansujiya_java_assign',
                    snapshotRepo: 'sureshkansujiya_java_assign'
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
				sh returnStdout: true, script: '/Applications/Docker.app/Contents/Resources/bin/docker build -t sureshkansujiya/dtr.javasample.suresh:${BUILD_NUMBER} -f Dockerfile .'
			}
		}

        stage ('Push to DockerHub')
	    {
		    steps
		    {
			sh '/Applications/Docker.app/Contents/Resources/bin/docker login -u "sureshkansujiya" -p "9462039286S" docker.io'
		    	sh returnStdout: true, script: '/Applications/Docker.app/Contents/Resources/bin/docker push sureshkansujiya/dtr.javasample.suresh:${BUILD_NUMBER}'
		    }
	    }

        stage ('Stop Running container')
    	{
	        steps
	        {
	            sh '''
                    ContainerID=$(/Applications/Docker.app/Contents/Resources/bin/docker ps | grep 7015 | cut -d " " -f 1)
                    if [  $ContainerID ]
                    then
                        /Applications/Docker.app/Contents/Resources/bin/docker stop $ContainerID
                        /Applications/Docker.app/Contents/Resources/bin/docker rm -f $ContainerID
                    fi
                '''
	        }
	    }

		stage ('Docker deployment')
		{
		    steps
		    {
		        sh '/Applications/Docker.app/Contents/Resources/bin/docker run --name devopssampleapplication_sureshkansujiya_java_assign -d -p 7015:8080 sureshkansujiya/dtr.javasample.suresh:${BUILD_NUMBER}'
		    }
		}
	}
	post 
	{
        always 
		{
			emailext attachmentsPattern: 'report.html', body: '${JELLY_SCRIPT,template="health"}', mimeType: 'text/html', recipientProviders: [[$class: 'RequesterRecipientProvider']], replyTo: 'suresh.kansujiya@nagrro.com', subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: 'suresh.kansujiya@nagrro.com'
        }
    }
}
