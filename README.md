## Deploy a web app to AWS ECS using Terraform Cloud

#### **Current Setup:**

_Initial Setup and App Frontend:_

1. Set up appropriate AWS access permissions for Terraform and enable AWS services
2. Create AWS Container Registry (ECR) repo
3. From the app_frontend directory, build Docker image and push to ECR

_Terraform:_

1. Take the ECR image URI and paste into the container definition section in main.tf. Also make sure the ECR repo name matches what was created in the above set up step.
2. Connect this repo containing terraform code and app code with Terraform Cloud
3. Run your usual commands: `terraform init` > `terraform plan` > `terraform apply --auto-approve`
4. See terraform output to access your web app url (app load balancer url)

#### **Future Improvements:**

1. Automate image build in the set up procedures so once app code is pushed to your repo, the image build is completed automatically
2. Connect the image build process with the terraform process via a CI/CD pipeline so that terraform is applied after the image is built. The image URI we manually pasted in step 1 of the current state will need to be dynamically updated based on the output of the image build process

**🙅🏻‍♀️DEMO ONLY - NOT FOR PROD USE🙅🏻‍♀️**
