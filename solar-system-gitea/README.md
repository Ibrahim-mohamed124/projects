# This is a repo of an app that give info about the solar-system
# this is version 1.0.0 more enhancement will come in the next releases
Required infrastrcutre 
1- Jenkins server
2- Linux machine with:
    docker
    trivy cli
    java-21
    aws cli 
    git
3- SonarQube server with the desired quality gate
4- Gitea server
5- an EC2 instance on AWS for continous deployment
6- an kubernetes cluster with ArgoCd installed for continous delivery
7- AWS Lambda function for production // this is only for learning purposes 
###########################################################################
Jenkins Plugins used:
  Basic Plugins Package
  AWS Steps
  AWS Credentials Plugin
  Bitbucket Branch Source
  Copy Artifact Plugin 
  Docker Pipeline 
  Gitea Plugin
  GitHub Authentication plugin
  HTML Publisher Version 
  JUnit Plugin
  Kubernetes :: Pipeline :: DevOps Steps
  OWASP Dependency-Check Plugin
  S3 publisher
  SonarQube Scanner for Jenkins Version 
  SSH Agent Plugin 
  SSH plugin
  Timestamper 
Jenkins Tools used:
  node.js installation tool
  sonarqubescanner installtion tool
  OWASP cli installtion tool
###########################################################################
What should you change in the Jenkinsfile:
1- your_local_mongodb_instance_ip
2- your_global_mongodb_instance_uri
3- your_ec2_instance_ip
4- your_gitea_ip
5- your_kubernetes_deployment_ip:port
##########################################################################



  
