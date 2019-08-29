# devops_proj
This project is intended automate the provisioning, configuring and deploying of simple HTMl web application using Terraform, Ansible and Jenkins. 

In this project four ec2 instances will be provisioned with terreform. 



Getting Started The below instruction will get you a copy of the project up and running on your local machine for development and testing.

Prerequisite Software requirement: CentOS 7 Terraform v0.12.6 Ansible 2.8.4 Jenkins OpennJDK 1.8.0 Git Apache(httpd)

Deployment Platform Amazon Webs Services

Installation To install the require software run the following step on your local machine:

Terraform # Run yum update on your local machine 1. sudo yum update

# The below step is optional
2. sudo yum install wget unzip 

#Go to Terraform website and download the binary package
3. wget http_url_for_dowload

#Unzip the binary
4. sudo unzip terraform_binary path -d path_to_new_location

#Run test to verify that Terraform is install
5. terraform -v
#Configuration 
6. Configuration instruction

Ansible # update your local machine 1. sudo yum update

#Install epel repo --- optional
2. sudo yum install epel-release

#Install ansible
3. sudo yum install ansible

#Run test to verify that Ansible is install
4. ansible --version

#Configuration 
5. Configuration instruction

Jenkins # update your local machine 1. sudo yum update

#Install the following package
2.sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
  sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
  sudo yum install java-1.8.0-openjdk wget
  sudo yum install jenkins

3. ansible --version

#Configuration instruction

Git #Install git if not already install 1. sudo yum install git

Deployment 1. A simple HTMl web app will be push to Github which will later be integrated and deploy with Jenkins. See below for more instruction.
