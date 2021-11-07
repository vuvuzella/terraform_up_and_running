## Terraform Up and Running project file

### To begin working on this repository:
1. Install Terraform
2. Modify the provider profile and region in main.tf
3. Modify the terraform backend in main.tf
4. If no s3 and dynamodb exist in the aws account for the shared state, comment out the `terraform` block
5. run `terraform init` in global/s3
6. run `terraform apply`
7. if the s3 and dynamodb is newly created, uncomment the `terraform block`, then run `terraform init`, then `terraform apply`

### Description of file structure

#### global/s3
* This folder contains infrastructure code for the s3 bucket that will be used to store the the state files of infrastructure made in the admin-dev aws account
* This also contains infrastrucure for the dynamoDB table that is used to perform state locking mechanism used by terrafrom in a shared state mode of deployment
* The infrastructure in this folder is run separately and at the beginning of establishing a global infrastructure for other projects that involves creating aws infrastructure in this aws account. 
* To deploy the global infrastructure, issue `terraform apply` inside this folder

#### modules
* Currently contains the Autoscaling Group made into a module

#### stage

##### services

###### webserver-cluster

##### data-stores

#### prod