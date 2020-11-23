By Rob Foster

Updated 22/11/2020

## Introduction
This is my submission for the 'Ensuring Quality Releases' project as part of the 'DevOps Engineer for Microsoft Azure' nanodegree program from [Udacity](https://udacity.com). It contains code for an azure devops CI/CD pipeline that does the following:

* Create a resource group and storage account in azure to store a terraform statefile.
* Publish a package called FakeRestAPI as an artifact.
* Build the following azure resources using terraform:
  * Resource group
  * App service
  * App service plan
  * Network interface
  * Network security group
  * Public IP address
  * Virtual machine
  * Disk
  * Virtual network
* Deploy FakeRestAPI as an azure app service.
* Run postman/newman data validation tests against the [http://dummy.restapiexample.com](http://dummy.restapiexample.com) API (not the API created above).
* Publish a selenium script (written in python) as an artifact.
* Install selenium on the VM and use it to run functional tests against the [https://www.saucedemo.com](https://www.saucedemo.com) website (not a website I deploy here).
* Set up email alerting for the app service (manual step in azure portal).
* Set up custom logging in log analytics to gather selenium logs from the VM (maunal step in azure portal).

<br/>

## Instructions

#### Create the service principal
Login to azure:
```
az login
```
Create a service principal for terraform with contributor rights for the subscription: 
```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

<br/>

#### Create and run the pipeline
Sign in to [azure devops](https://azure.microsoft.com/en-us/services/devops/?nav=min) and create a new project.

Go to **Project Settings** > **Service Connections** > **New Service Connection** > **Azure Resource Manager** > **Next** > **Service Principal (Automatic)** > **Next** > **Subscription**. Choose your subscription and give the service connection the same name as your subscription.

Create a pipeline connected to github and select this repo. The [azure-pipelines.yml](azure-pipelines.yml) file should appear. Create the following variables via the GUI (an explanation of each is given below):
* **adminusername** - the admin account for the VM.
* **appservice** - the name of the app service to be created.
* **azureenvironment** - the name of the environment to be created in azure devops.
* **azuresubscription** - the name of the subscription.
* **clientid** - the appid of the service principal
* **clientsecret** - the password of the service principal.
* **location** - the region to create the azure resources in.
* **prefix** - a name to prefix to the azure resources.
* **publickey** - the public key that corresponds with the private key to be used for SSH access to the VM.
* **resourcegroup** - the name of the resource group to create the app service and VM in (this is a different resource group to the one that will store the terraform statefile).
* **storagekey** - give this the value of 'placeholder', as it will be updated with the real value when the pipeline runs.
* **subscriptionid** - the azure subscription ID.
* **tenantid** - the azure tenant ID.
* **terraformstorageaccount** - the name of the storage account for storing the terraform statefile.
* **terraformstoragerg** - the name of the resource group for storing the terraform statefile (this is a different resource group to the one that will store the app service and VM).

Run the pipeline. On the first run it will fail on the seleniumOnVMDeploy deployment. This is because we need to manually configure the VM to allow the pipeline to connect to it. To do so, go to **Pipelines** > **Environments**. Click your environment > **Add Resource** > **Virtual Machines** > **Next**. Select **Linux** operating system. Copy the registration script to the clipboard. Then SSH to the VM using your private key and public IP of the VM:
```
ssh -i ~/path/to/privatekey robadmin@20.68.27.85
```
Paste the registration script into the terminal (don't use sudo). Select N for tags, Y for unzip. The VM can now be managed by the pipeline. Re-run the failed job. The pipeline run should complete successfully. 

If the app service is not running properly, it may not have deployed correctly. Running the pipeline again may resolve this. 

<br/>

#### Set up email alerts
In the azure portal go to the app service > **Alerts** > **New Alert Rule**. Add an HTTP 404 condition and add a threshold value of 1. This will create an alert if there are two or more consecutive 404 alerts. Click **Done**. Then create an action group with notification type **Email/SMS message/Push/Voice** and choose the email option. Set the alert rule name and severity. Wait ten minutes for the alert to take effect.
If you then visit the URL of the app service and try to go to a non-existent page more than once it should trigger the email alert.

<br/>

#### Set up log analytics
Go to the app service > **Diagnostic Settings** > **+ Add Diagnostic Setting**. Tick **AppServiceHTTPLogs** and **Send to Log Analytics Workspace**. Select a workspace (can be an existing default workspace) > **Save**. Go back to the app service > **App Service Logs**. Turn on **Detailed Error Messages** and **Failed Request Tracing** > **Save**. Restart the app service. 

Go to the log analytics workspace > **Logs**. Run the following query:
```  
Operation
| where TimeGenerated > ago(2h)
| summarize count() by TimeGenerated, OperationStatus, Detail
```
This should show some log results (though it may take an hour or so before they appear).

<br/>

#### Set up custom logging
In the log analytics workspace go to **Advanced Settings** > **Data** > **Custom Logs** > **Add +** > **Choose File**. Select the file  **[selenium.log](automatedtesting/selenium/selenium.log)** > **Next** > **Next**. Put in the following paths as type **Linux**:
* /var/log/selenium/selenium.log
* /var/log/selenium
* /var/log/selenium/*.log

Give it a name and click **Done**. Tick the box **Apply below configuration to my linux machines**.

Go back to the log analytics workspace > **Virtual Machines**. Click your VM > **Connect**. This will install the agent on the VM, allowing azure to collect logs from it.

Go back to the log analytics workspace > **Logs**. From the **Custom Logs** dropdown double-click the custom log just created and run the query. You should see the selenium logs. However, the agent might only collect logs if the timestamp on the log file was updated after the agent was installed. Also, the VM might require a reboot, or you might just need to wait a while, before the logs appear.
