FROM tomcat:alpine
MAINTAINER DevOps Team
RUN wget -O /Users/sureshkansujiya/Downloads/node_passport_login-master/launchstation04.war http://10.127.126.48:8040/artifactory/sureshkansujiya/com/nagarro/devops-tools/devops/demosampleapplication/1.0.0-SNAPSHOT/demosampleapplication-1.0.0-SNAPSHOT.war
EXPOSE 8000
CMD /usr/local/tomcat/bin/catalina.sh run
