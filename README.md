# Demonstration of Implementing DevOps CI/CD on Huawei Cloud DevCloud

### 1.0 Introduction

DevCloud is a one-stop, cloud-based DevOps platform that provides a bundle of out-of-the-box cloud services covering requirement delivery, code commit, code build, verification, deployment, and release. DevCloud streamlines software delivery, provides end-to-end software R&D support, and enables you to fully implement DevOps. 

![figure1](.others/images/figure1.jpg)

<p align="center"> Figure 1.0 : DevCloud Architecture </p>

**In this walk-through we are going to achieve the below objectives:**
* To build the demo environment by using Terraform to provision Kubernetes cluster with Huawei Cloud Container Engine (CCE).
* To build a CI/CD pipeline to automate the process of application deployment in Huawei Cloud Container Engine (CCE) using Huawei DevCloud.
* To demonstrate the Blue/Green deployment strategy using Huawei DevCloud.
* To illustrate application version control and version rollback by utilizing features offered in Huawei DevCloud. 

### 2.0 Solution Overview

In this walk-through, we are going to demonstrate how to use Huawei DevCloud to build CI/CD pipeline for DevOps purposes. The solution is as shown below that illustrate two different automated pipelines used in different environments namely automated continuous integration (CI) pipeline that deploy application in development, system integration testing and user acceptance test environment, and automated continuous deployment (CD) pipeline that deploy application in production environment. The automated pipelines utilize the features provided in Huawei DevCloud such as CodeHub, CodeCheck, CloudBuild and CloudDeploy which integrate with Huawei Cloud services such as Software Repositories Warehouse (SWR) and Cloud Container Engine (CCE). The overall solution is to deploy a demo application with image tagging to testing environment before it can release to production environment with an approval from project manager to determine which version to release.

![figure2](./images/figure2.jpg)

<p align="center"> Figure 2.0 : Automated CI/CD pipeline Flow Diagram </p>

**The roles and functions of each of the elements used in this walkthrough is briefly describe as below:**
* CodeHub: Git-based online code hosting service for software developers that aims to provide code version management and multi-branch concurrent development.
* CloudBuild: Seamlessly interconnected with CodeHub to enable cloud-based compilation and building. It provides robust features such as automation of code retrieval, build and packaging application, and real-time status monitoring.
* CloudDeploy: Provides visualized and one-click deployment on hosts such as containers in Cloud Container Engine. It supports various system such as Kubernetes, provides flexible assembly and orchestration of atomic actions and parallel deployment and seamless pipeline integration for automatic and continuous release.
* CloudPipeline: A visualized and automated task scheduling platform that used together with automated task services such as CodeHub, CloudBuild and CloudDeploy in DevCloud. Allow orchestration of these automation tasks based on requirements such as application deployment in development, test or production environment. After tasks are configured, they can be automatically triggered, scheduled and executed by avoiding frequent and inefficient manual operations.
* Software Repository for Container (SWR): Host container images from CloudBuild and allow the pulling of container image for application deployment in Cloud Container Engine of different environment.

### 3.0 Prerequisites

**For this walk-through, you should have familiarity with the following concepts:**
* Huawei Cloud Services:
    * Huawei Cloud DevCloud
    * Virtual Private Cloud (VPC)
    * Cloud Container Engine (CCE)
    * Software Repository for Container (SWR)
    * How to use Terraform to provision Huawei Cloud resources
* Before getting started, complete the following prerequisites:
    * Download and install Terraform. Steps can be found below at 4.1.
    * Create a Huawei Cloud master account and add sub-accounts under the master accounts. Steps can refer to 4.2 below.
    * Obtain Access key & Security Key at My credentials > Access keys > Create Access key.

![figure3](./images/figure3.jpg)

<p align="center"> Figure 3.0 : Huawei Credentials </p>

### 4.0 Getting Start

#### 4.1 Download and Install Terraform

Terraform by HashiCorp, is an “infrastructure as code” that allows you  to build, change, and version infrastructure safely and efficiently. In this demo, we will going to use Terraform (IaC) to automate the provisioning of cloud resources in Huawei Cloud. Step of installation as below:
* Download proper package for you operating system and architecture from Terraform Official Website.
* Install Terraform by unzipping it and moving it to a directory included in your system's PATH.
* Verify that the installation worked by opening a new terminal session and listing Terraform’s available sub-commands.

```$ terraform -help```

```Usage: terraform  [-version] [-help] <command> [args]```
 
```The available commands for execution are listed below. The most common, useful commands are shown first, followed by less common or more advanced commands. If you're just with Terraform, stick with the common commands. For the other commands, please read the help and docs before usage. ##...```

* Note: If you get an error that Terraform could not be found, your PATH environment variable was not set up properly. Please go back and ensure that your PATH variable contains the directory where Terraform was installed.

#### 4.2 Multi-account Structure

In this walk-through, we will be using three different environments with each of it have its own purpose as shown in diagram below. The environments is created in three different sub-accounts in which the billing is controlled by a master account. The multi-account structure is to ease the management of the resources and restrict the access of multiple developer teams which specific to dedicated resources and accounts.

![figure4](./images/figure4.jpg)

<p align="center"> Figure 4.0 : Multi-account Structure for Demo Environment </p>

##### 4.2.1 Create Sub-Account
1. Log in to your master account at https://auth.huaweicloud.com/authui/login.html?locale=en-us&service=https%3A%2F%2Fwww.huaweicloud.com%2Fintl%2Fen-us%2F#/login using your credentials.

![figure4.1](./images/figure4.1.jpg)

<p align="center"> Figure 4.1 : Huawei Login Page </p>

2.	On the console page, at the navigation pane, click More > Enterprise > Organizations and Accounts

![figure4.2](./images/figure4.2.jpg)

<p align="center"> Figure 4.2 : Huawei Cloud Management Console </p>

3.	In Organization and Accounts page, click Add Member Accounts as shown in Figure 4.3.

![figure4.3](./images/figure4.3.jpg)

<p align="center"> Figure 4.3 : Organization and Accounts in Enterprise Center </p>

4.	Click Create Member Account.

![figure4.4](./images/figure4.4.jpg)

<p align="center"> Figure 4.4 : Organization and Accounts in Enterprise Center </p>

5.	In the displayed page, set the parameter as prompted and click Next.

![figure4.5](./images/figure4.5.jpg)

<p align="center"> Figure 4.5 : Member accounts configuration </p>

6.	Tick the checkbox as below and click Next.

![figure4.6](./images/figure4.6.jpg)

<p align="center"> Figure 4.6 : Member account’s configuration </p>

7.	Click Obtain Verification Code. Check your email address to obtain the verification code. After fill in the verification code. Click Submit.

![figure4.7](./images/figure4.7.jpg)

<p align="center"> Figure 4.7 : Verification Code in creating member account </p>

##### 4.2.2 Allocating Budget to Sub-Account
In order to create resources in Sub-Account, It is necessary to allocate the budget to sub-account. Steps are as below:
1.	On the console page, at the navigation pane, click More > Enterprise > Organizations and Accounts.
2.	In the navigation pane on the left, choose Accounting Management > Budget Management. 

![figure4.8](./images/figure4.8.jpg)

<p align="center"> Figure 4.8 : Allocating Budget to sub-account </p>

3.	On the Budget Management page, choose BudgetAllocation tab. Locate the member and click Allocate.

![figure4.9](./images/figure4.9.jpg)

<p align="center"> Figure 4.9 : Allocating Budget to sub-account </p>

4.	Fill in the Amount to Allocate (USD) and click Submit.

![figure4.10](./images/figure4.10.jpg)

<p align="center"> Figure 4.10 : Allocating Budget to sub-account </p>

#### 4.3 DevOps Environment Preparation

##### 4.3.1 Access to DevCloud Console
1.	Click on this link https://devcloud.ap-southeast-3.huaweicloud.com/home to access to DevCloud.

##### 4.3.2 Create New Project
1.	the DevCloud homepage, click Create Project to create new project.
2.	Configure the parameter as prompted.
3.	Click OK

![figure4.11](./images/figure4.11.jpg)

<p align="center"> Figure 4.11 : Create new project in DevCloud console </p>

![figure4.12](./images/figure4.12.jpg)

<p align="center"> Figure 4.12 : Create new project in DevCloud console </p>

##### 4.3.3 Creating Repository in CodeHub
In this demo, we will use CodeHub for storing, tracking, and collaborating on software projects. It’s version control system, which allows for seamless collaboration without compromising the integrity of the original project. Steps of creating Repository in CodeHub is shown below:
1.	On DevCloud homepage, at the top navigation bar, click DevCloud > CodeHub.

![figure4.13](./images/figure4.13.jpg)

<p align="center"> Figure 4.13 : CodeHub management console in Huawei DevCloud </p>

2.	On the CodeHub page, click Create Directly.
3.	Configure the parameter as prompted.

![figure4.14](./images/figure4.14.jpg)

<p align="center"> Figure 4.14 : CodeHub management console in Huawei DevCloud </p>

##### 4.3.4 Set SSH key
When working with a CodeHub repository, you'll need to identify yourself to CodeHub using your username and password. An SSH key is an alternate way to identify yourself that doesn't require you to enter you username and password every time.
1.	Create SSH key in the terminal.
```ssh-keygen```
2.	Check the SSH key generated in .ssh folder as below.

![figure4.15](./images/figure4.15.jpg)

<p align="center"> Figure 4.15 : SSH key generation using ssh-keygen in CLI </p>

```cd /root/.ssh/```
```cat id_rsa.pub```

3.	On the CodeHub page, click the setting icon beside the Create Directly button and select Set SSH Key. 

![figure4.16](./images/figure4.16.jpg)

<p align="center"> Figure 4.16 : CodeHub management console in Huawei DevCloud </p>

4.	Click Add SSH Key on displayed page.

![figure4.17](./images/figure4.17.jpg)

<p align="center"> Figure 4.17 : SSH key configuration in DevCloud console </p>

5.	On the displayed page, paste the SSH key generated.
6.	Tick the checkbox and click OK.

![figure4.18](./images/figure4.18.jpg)

<p align="center"> Figure 4.18 : SSH key configuration in DevCloud console </p>

7.	Procedure to generating SSH key can refer here.

##### 4.3.5 Clone Repository to Local Environment.
When you clone a repository, you don't get one file, like you may in other centralized version control systems. By cloning with Git, you get the entire repository - all files, all branches, and all commits.

Cloning a repository is typically only done once, at the beginning of your interaction with a project. Once a repository already exists on a remote, then you would clone that repository so you could interact with it locally. Once you have cloned a repository, you won't need to clone it again to do regular development.
1.	Click the directly that create above to go into the directly homepage.
2.	On the directly homepage, click Clone/Download and copy the ssh link as prompted below.

![figure4.19](./images/figure4.19.jpg)

<p align="center"> Figure 4.19 : CodeHub repository in Huawei DevCloud </p>

3.	Go back to terminal, clone the repository with git clone command.

### 5.0 Demonstration

The demo in this walk-through includes three different scenarios that deploy a demo application in testing and production environment by using automated CI/CD pipeline. The subtopic for each demo is as listed below.
* Demo#1 : Automated continuous integration, version control, and release to DEV/SIT/UAT environments
* Demo#2 : Blue-Green deployment strategy for production environment
* Demo#3 : Version control rollback for production environment

#### 5.1 Demo #1 : Automated continuous integration, version control, and release to DEV/SIT/UAT environments

**Purpose:** In this demo, we’re going to automate the continuous integration for DEV/SIT/UAT environments with the used of CI pipeline. Developer who is responsible for the code development and changes are required to submit code to the CodeHub repository by using Git command. New commit to the CodeHub will trigger the process of CloudBuild that create the demo-apps container image which then perform tagging and push the image to Software Repository for Container (SWR). CloudDeploy will deploy the image to Huawei Cloud Container Engine (CCE) cluster that resides in either DEV, SIT or UAT environment before the application can run in production environment. 

![figure5.0](./images/figure5.0.jpg)

<p align="center"> Figure 5.0 : Automated CI Pipeline Flow Diagram in SIT Environment </p>

The pipeline will be built in the DevOps account and the deployment will be deployed in SIT account. Before we can build the CI pipeline by using DevCloud in the DevOps account, we need to subscribe to the package in order to activate the services. In Singapore region of DevOps account, navigate to the DevCloud console, and subscribe to all the necessary services including CodeHub, CloudBuild, CloudRelease, CloudPipeline and CloudDeploy as shown in example screenshots below.

**Step by steps to subscribe DevCloud services:**
Subscribe the DevCloud services as shown in Figure 5.1.

![figure5.1](./images/figure5.1.jpg)

<p align="center"> Figure 5.1 : Huawei DevCloud CloudBuild Subscription Page </p>

Once subscription done, click the button on the upper right corner to access the DevCloud service as shown in Figure 5.2.

![figure5.2](./images/figure5.2.jpg)

<p align="center"> Figure 5.2 : Huawei DevCloud Management Console </p>

Please follow below steps to build a CI pipeline in DEV/SIT/UAT environment. It is separated into three different parts namely CloudBuild, CloudDeploy and CloudPipeline.‘ 

##### 5.1.1 CloudBuild
The usage of CloudBuild in this walk-through is to package and build a container image from software code stored in CodeHub and push the image to SWR for further application deployment in Huawei Cloud Container Engine. 

Step 1: To build a CI pipeline, we need to configure the task in CloudBuild and CloudDeploy. On the console bar, select CloudBuild as shown in Figure 5.3.

![figure5.3](./images/figure5.3.jpg)

<p align="center"> Figure 5.3 : Huawei DevCloud Workspace </p>

Step 2: Create a new task in CloudBuild with the selected CodeHub repository in which your development code stored. Retain the default code branch as a master branch.

![figure5.4](./images/figure5.4.jpg)

<p align="center"> Figure 5.4 : CloudBuild - Initial Configuration and Setup </p>

Step 3: Choose a blank template in this demo.

![figure5.5](./images/figure5.5.jpg)

<p align="center"> Figure 5.5 : CloudBuild - Initial Configuration and Setup </p>

Step 4: Before we configure the build actions, create the custom parameter as shown below to be used in the function in build actions later. The parameter value of buildVersion is v1.$(INCREASENUM) indicates for every build of the container image will increment by a value of 0.1.

![figure5.6](./images/figure5.6.jpg)

<p align="center"> Figure 5.6 : CloudBuild - Custom Parameter Settings </p>

Step 5: Next, configure the build actions in CloudBuild. Select the function named Build Image and Push to SWR as shown in Figure 5.7.

![figure5.7](./images/figure5.7.jpg)

<p align="center"> Figure 5.7 : CloudBuild - Build Action Functions </p>

Step 6: If you already have an organization created in SWR, please skip this step and proceed to the next. If you do not have an organization created in SWR, please create one by navigating to the SWR console. Under organization management, click the create organization button at the upper right corner. Input your organization name and enter save. 

![figure5.8](./images/figure5.8.jpg)

<p align="center"> Figure 5.8 : SWR Organization Management </p>

Step 7: Insert the custom parameters that create in the previous step as your Image Name and Image Tag by using the dollar signs and bracket. Input your SWR organization name while retaining other values as default as shown in Figure 5.9.

![figure5.9](./images/figure5.9.jpg)

<p align="center"> Figure 5.9 : CloudBuild - Build Image and Push to SWR </p>

Step 8: Select the second function named as Upload to Release Repository. You may insert any name as your folder directory to store your build package. In this demo, we stored the build package in the Fixed-Release-Version folder as shown in Figure 5.10.

![figure5.10](./images/figure5.10.jpg)

<p align="center"> Figure 5.10 : CloudBuild - Upload to Release Repository </p>

Step 9: Test run the CloudBuild to verify that the image is built and pushed to SWR.

![figure5.11](./images/figure5.11.jpg)

<p align="center"> Figure 5.11 : CloudBuild - Running the Build Task </p>

##### 5.1.2 CloudDeploy
The usage of CloudDeploy in this walk-through is to deploy a demo application to the Kubernetes cluster of Huawei Cloud-native service, Cloud Container Engine. The container image used is pulled from SWR by granting permission to a shared account for application deployment in a cluster.

Step 1: In this part of the configuration, we required to provision a cluster in SIT account using Terraform in order to deploy an application on it. Below shows an example of configuration scripts to provision the Kubernetes cluster in Huawei CCE. You may obtain the script file in the folder of App_Demo_Code.zip file in Appendix section. Run the scripts in your local machine by using Terraform command as shown below.
```terraform init```
```terraform plan```
```terraform apply -auto-approve```

![figure5.12](./images/figure5.12.jpg)

<p align="center"> Figure 5.12 : Provision Kubernetes Cluster in Huawei CCE </p>

Step 2: Once provision cluster successfully in Huawei CCE, obtain the kubectl configuration scripts to be used in CloudDeploy in a later step as shown in Figure 5.13.

![figure5.13](./images/figure5.13.jpg)

<p align="center"> Figure 5.13 : Obtain kubectl configuration scripts in Huawei CCE management console </p>

Step 3: Navigate back to CloudDeploy console page, and create a new task in CloudDeploy. Insert your desired task name and the created project name.

![figure5.14](./images/figure5.14.jpg)

<p align="center"> Figure 5.14 : CloudDeploy - Initial Configuration </p>

Step 4: Select a blank template.

![figure5.15](./images/figure5.15.jpg)

<p align="center"> Figure 5.15 : CloudDeploy - Initial Configuration </p>

Step 5: Before configuring the build actions, create the custom parameter to be used in configuration later. Enter the SWR url and organization name that obtain from SWR console. In this demo, our image is stored in the Singapore region and the endpoint is as shown in Figure 5.16 below. Specify the latest build version number as the default value of buildVersion parameter.

![figure5.16](./images/figure5.16.jpg)

<p align="center"> Figure 5.16 : CloudDeploy - Custom Parameter Settings </p>

Step 6: Select a function named as Deploy an Application on Kubernetes Clusters. Configure the Kubernetes cluster service endpoint by clicking on the create button as shown below.

![figure5.17](./images/figure5.17.jpg)

<p align="center"> Figure 5.17 : CloudDeploy - Deployment Actions Configuration </p>

Step 7: Enter the Kubernetes URL and content of Kubeconfig that obtained in Step 2.

![figure5.18](./images/figure5.18.jpg)

<p align="center"> Figure 5.18 : CloudDeploy - Kubernetes Service Endpoints Configuration </p>

Step 8: Use kubectl apply command in this task and the file source is the yaml files that stored in Release repository. Enter the folder directory where we stored the deployment code. Click the save button once the configuration done.

![figure5.19](./images/figure5.19.jpg)
![figure5.20](./images/figure5.20.jpg)

<p align="center"> Figure 5.19 : CloudDeploy - Deploy an Application on Kubernetes Cluster Configuration </p>

Step 9: Configure next task by using two different functions such as run shell commands and run shell scripts as shown in Figure below to conduct the unit test.

![figure5.20a](./images/Figure5.20a.PNG)
![figure5.20b](./images/Figure5.20b.PNG)

<p align="center"> Figure 5.20 : CloudDeploy - Unit Test in Testing Environment </p>

##### 5.1.3 CloudPipeline
CloudPipeline combined all the pre-configured tasks such as CodeHub, CloudBuild and CloudDeploy to automate the process of code development, application containerization, image tagging, version control, and application deployment in the Kubernetes cluster of Cloud Container Engine.

Step 1: Navigate to the CloudPipeline console page to create a new CI pipeline. Retain the default values for project, repository, and, branch if you have only one project and CodeHub repository at the current moment. If you have multiple projects and repositories, select the correct one to be used in this pipeline. 

![figure5.21](./images/figure5.21.jpg)

<p align="center"> Figure 5.21 : CloudPipeline - Initial Configuration </p>

Step 2: Select a blank template.

![figure5.22](./images/figure5.22.jpg)

<p align="center"> Figure 5.22 : CloudPipeline - Initial Configuration </p>

Step 3: Configure the execution plan of the pipeline as triggered when the code is committed.

![figure5.23](./images/figure5.23.jpg)

<p align="center"> Figure 5.23 : CloudPipeline - Execution Plan </p>

Step 4: Configure the custom parameter of the image name as a different name from the previous step. 
This is to separate the image created from the pipeline.

![figure5.24](./images/figure5.24.jpg)

<p align="center"> Figure 5.24 : CloudPipeline - Custom Parameter Settings </p>

Step 5: Enter a meaningful name for the pipeline.

![figure5.25](./images/figure5.25.jpg)

<p align="center"> Figure 5.25 : CloudPipeline - Basic Information </p>

Step 6: Configure the workflows for the pipeline. Click the plus sign button and configure the task as shown below. This task is to build and package the image to be pushed to SWR. The buildVersion is using the TIMESTAMP pre-defined parameter so that the image build is tag with the timestamp. For example, the image tag version is v1.0-20220504195040.

![figure5.26](./images/figure5.26.jpg)

<p align="center"> Figure 5.26 : CloudPipeline - Workflow Configuration </p>

Step 7: Configure the next task by setting the same parameter as previous step. This task is to deploy the application to CCE cluster, select the task that had configured previously in CloudDeploy as shown in Figure 5.27. Next, configure another task for unit test that had pre-configured in previous step.

![figure5.27](./images/figure5.27.jpg)
![figure5.27b](./images/Figure5.27b.PNG)

<p align="center"> Figure 5.27 : CloudPipeline - Workflow Configuration </p>

Step 8: Be noted that our private image is stored in SWR of DevOps account where our deployment is in SIT account. We need to share the private image to the SIT account in order to gain access for pulling the image as shown in Figure 5.28 below. Without sharing the image, the deployment in SIT account will not be successful as it will result in a failure to pull the image from the software repository.

![figure5.28](./images/figure5.28.jpg)

<p align="center"> Figure 5.28 : Shared Image in SWR </p>

![figure5.29](./images/figure5.29.jpg)

<p align="center"> Figure 5.29 : Shared Image in SWR </p>

Step 9: Commit changes to our deployment code by using git commit and git push to trigger the pipeline as shown in Figure 5.30. 

![figure5.30](./images/figure5.30.jpg)

<p align="center"> Figure 5.30 : Commit changes to CodeHub by using Git command </p>

Step 10: Navigate to the CloudPipeline console page to observe the build. Figure 5.31 below indicates the build was successful.

![figure5.31](./images/figure5.31.jpg)

<p align="center"> Figure 5.31 : Commit changes to CodeHub by using Git command </p>

Step 11: Navigate to the CCE console page in SIT account, under the workloads of the pod, and observe the status whether it is running or abnormal. It may take some time for the pod to be up and running.

![figure5.32](./images/figure5.32.jpg)

<p align="center"> Figure 5.32 : Observe the deployment status in Huawei CCE management console </p>

Step 12: Once the status of pod is up and running, subscribe a service to allow the external access of pods. Navigate to the network under resource management in the left, select create service, configure the parameters as in Figure 5.33 and Figure 3.34.

![figure5.33](./images/figure5.33.jpg)

<p align="center"> Figure 5.33 : Configure service for the deployment workloads </p>

![figure5.34](./images/figure5.34.jpg)

<p align="center"> Figure 5.34 : Observe the deployment status in Huawei CCE management console </p>

Step 13: Observe the service is successfully created and bind to the workloads.
![figure5.35](./images/figure5.35.jpg)

<p align="center"> Figure 5.35 : Observe the deployment status in Huawei CCE management console </p>

Step 14: Use the external IP address to access the workloads. If you able to see the webpage as similar to the Figure 5.36, it indicates the deployment is successful.
![figure5.36](./images/figure5.36.jpg)

<p align="center"> Figure 5.36 : Displayed webpage in web browser </p>

5.2 Demo #2 : Blue-Green deployment strategy for production environment

![figure5.37](./images/figure5.37.jpg)

<p align="center"> Figure 5.37 : Automated CD Pipeline Flow Diagram in Prod Environment </p>

**Purpose:** In this demo, we’re going to deploy the application in production environment based on the final version of image tag in test environment using automated CD pipeline. There are two key persons here which is test manager and project manager. The test manager will submit a request to promote the application with specific image tag to a production environment while the project manager will review the request and decides whether to approve to go live or reject the request. The process and steps are similar to Demo #1 but with an additional task of email notification to approve the application to go live.  
 
The terminology used in this scenario is Blue Green deployment where there are two deployments, one indicates stable version and another indicates new release version exist in production environment. In this demo, we will use blue and green version of application to represent two different deployments to be deployed in production environment as shown in Figure 5.38.

![figure5.38](./images/figure5.38.jpg)

<p align="center"> Figure 5.38 : Blue Green Deployment </p>

In the first deploy, the blue version is a latest and stable version that had tested in test environment and released to production environment. In the second deploy, the release version is a newest green version and remains idle. Once the newest green version is stable and run smoothly, we will patch the service to new green version and the blue version will become idle. We remain two versions of application in production environment is to enable the switch of the services to another version in case of failure with minimum downtime. Please follow the step below to build the automated CD pipeline.

Step 1: Provision a Kubernetes cluster in production account. Obtain the kubeconfig scripts and Kubernetes URL to configure the service endpoints in CloudDeploy. Configure the parameter as shown in Figure 5.39 and Figure 5.40.

![figure5.39](./images/figure5.39.jpg)

<p align="center"> Figure 5.39 : CloudDeploy - Deploy an Application on Kubernetes Clusters </p>

![figure5.40](./images/figure5.40.jpg)

<p align="center"> Figure 5.40 : CloudDeploy - Deploy an Application on Kubernetes Clusters </p>

Step 2: Create a new pipeline in CloudPipeline and configure the custom parameter as shown below. 
![figure5.41](./images/figure5.41.jpg)

<p align="center"> Figure 5.41 : CloudPipeline - Custom Parameter Settings </p>

Step 3: Add a new task in CloudPipeline to build and pushed image to SWR and follow the parameter as shown below.
![figure5.42](./images/figure5.42.jpg)

<p align="center"> Figure 5.42 : CloudPipeline - workflow configuration </p>

Step 4: Add a new task as manual review from Project Manager before deploy the application to production environment. Set the review duration accordingly as needed. 
![figure5.43](./images/figure5.43.jpg)

<p align="center"> Figure 5.43 : CloudPipeline - workflow configuration </p>

Step 5: Add another task to deploy the application to production environment. Select the task created in CloudDeploy in Step 1 for this demo purpose.
![figure5.44](./images/figure5.44.jpg)

<p align="center"> Figure 5.44 : CloudPipeline - workflow configuration </p>

Step 6: Save the configuration and manually run the pipeline by click on the execute button. Confirm the build version and image name before start the pipeline.
![figure5.45](./images/figure5.45.jpg)

<p align="center"> Figure 5.45 : CloudPipeline - Runtime parameter configuration </p>

Step 7: An email approval notification would be sent to the project manager to confirm the deployment. Click on the link provided in email, confirm the build version and approve the deployment once confirmed.
![figure5.46](./images/figure5.46.jpg)

<p align="center"> Figure 5.46 : Email approval notification from Huawei DevCloud CloudPipeline </p>

![figure5.47](./images/figure5.47.jpg)

<p align="center"> Figure 5.47 : Notification window prompt for deployment approval from Project Manager </p>

Step 8: Once the deployment successful, navigate to the production account to check for the deployment. Once the deployment is up and running, bind an ELB as shown below for the deployment workload and obtain the external access IP address. 

![figure5.48](./images/figure5.48.jpg)

<p align="center"> Figure 5.48 : ELB binding and networking services configuration </p>

Step 9: Open your web browser and browse the external IP address together with configured port number. If you see the webpage similar to the Figure 5.49 below, it indicates the deployment successful. Be noted that the image is an exact copy from the SIT environment, the website shown must be the same as in the SIT environment.

![figure5.49](./images/figure5.49.jpg)

<p align="center"> Figure 5.49 : Webpage displayed on web browser </p>

Step 10: Next, we will release a new version with green color background as our second deployment in production environment. Change the execution plan in our created pipeline so that the pipeline would triggered when the code is committed.

![figure5.50](./images/figure5.50.jpg)

<p align="center"> Figure 5.50 : Pipeline execution plan in production environment </p>

Step 11: Navigate to production account, under CCE, check whether the deployment is successful. In this moment, we should have two deployments running at the same time with blue deployment having an external access IP address and another green deployment as idle.

Step 12: In our local machine, connect to production cluster by using command as shown below.
```kubectl cluster-info```
```chmod +x kubectl```
```sudo mv -f kubectl /usr/local/bin```
```mkdir -p $HOME/.kube```
```mv -f kubeconfig.json $HOME/.kube/config```
```kubectl config use-context internal```
```kubectl config use-context external```

![figure5.51](./images/figure5.51.jpg)

<p align="center"> Figure 5.51 : Connection to Kubernetes cluster of Huawei CCE in local machine </p>

Step 13: Switch the service from blue deployment to green deployment by using command as shown below.
```kubectl -n ns-devops patch service svc-prod-demo -p ‘{"spec":{“selector”:{“app”: “php-fpm-nginx-green”}}}'```

![figure5.52](./images/figure5.52.jpg)

<p align="center"> Figure 5.52 : Patch the service to new release green deployment </p>

Step 14: Access the external IP address and observe the webpage had change to green color.

![figure5.53](./images/figure5.53.jpg)

<p align="center"> Figure 5.53 : External access address changed to green deployment </p>

![figure5.54](./images/figure5.54.jpg)

<p align="center"> Figure 5.54 : External access address changed to green deployment </p>

Step 15: (Optional) Enter the command below if you wish to switch back the deployment to blue version.
```kubectl -n ns-devops patch service svc-prod-demo -p ‘{"spec":{“selector”:{“app”: “php-fpm-nginx”}}}'```

#### 5.3 Demo #3 : Version control rollback for production environment

**Purpose:** DevCloud provide the features where developers are able to roll back the version of application to previous version in running environment when there is a failure of the application. This minimizes the service downtime and ensures that the user experience is not affected too much. In this demo, the project manager is responsible to confirm the issue and perform the version rollback operation with a specific version number.

![figure5.55](./images/figure5.55.jpg)

<p align="center"> Figure 5.55 : Version Rollback Flow Diagram </p>

From Demo #2, the current version is green version with green color background. We need to rollback the version to the initial version which is red color version that had built. There are two ways to perform version rollback, which is by using console and kubectl command. Please refer to the step below to perform version rollback.
 
Step 1: In a local machine that is connected to production cluster, insert the command below to roll back the version from green to red as shown in Figure 5.56.
```kubectl rollout undo -n ns-devops deployment php-fpm-nginx —to-revision=1```

![figure5.56](./images/figure5.56.jpg)

<p align="center"> Figure 5.56 : Version rollback using kubectl command </p>

Step 2: Observe the changes in the webpage. The background had changed to red color.

![figure5.57](./images/figure5.57.jpg)

<p align="center"> Figure 5.57 : Webpage displayed in web browser </p>

Step 3: To perform version rollback in console page, navigate to the CloudDeploy console page. Select the execution number and click the button as shown in Figure 5.58 to perform the version rollback.

![figure5.58](./images/figure5.58.jpg)

<p align="center"> Figure 5.58 : CloudDeploy - Version rollback in management console </p>

### 6.0 Appendix

Name | File
------------------------|------------------------
Example Code | App_Demo_Code.zip
Example of Design Table | CICD-Design Table.xlsx

### 7.0 Clean & remove resources

When you’re done experimenting with DevCloud, it’s a good idea to remove all the resources you created so Huawei Cloud doesn’t charge you for them. 

### 8.0 Conclusion

You now have a basic grasp of how to use DevCloud to automate the process of packaging software code, build image, containerized application, deployment in different environments, and basic knowledge on how to create resources in Huawei Cloud with management console and Terraform.
