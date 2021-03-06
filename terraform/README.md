
Terraform and AWS Build
=======================

Creates a auto-scaling ECS cluster of 5 t2.micro instances, codebuilds, datasync backup/restore scripts, Cloudfront w/Let's Encrypt SSL auto-updated by a Lambda script, route53 DNS records and a Bastion server (Jumphost)


## Prerequisites:
  * Terraform [Mac Install](https://learn.hashicorp.com/tutorials/terraform/install-cli) [Linux Install](https://learn.hashicorp.com/tutorials/terraform/install-cli)
  * AWS Cli [Mac Install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html) [Linux Install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)

## Configure a .env file for the docker build
  * `cp .env.sample .env`
    * [Env file options](https://github.com/wushin/ttrpg-tools#env-file-options)

## Set-up AWS main account
  * [Create a free Account](https://portal.aws.amazon.com/billing/signup#/start)
  * [Sign into the Account](https://console.aws.amazon.com/console/home?nc2=h_ct&src=header-signin)
  * Go To [My Security Creditials](https://console.aws.amazon.com/iam/home?region=us-east-1#security_credential)
    * To Create Access Keys Click on `Access keys (access key ID and secret access key)`
    * Create AWS Profile in ~/.aws/credentials or use `aws configure` 
```
[ttrpg-root]
aws_access_key_id = <Access Key ID>
aws_secret_access_key = <Access Key Secret>
```

## Set-up Users (IAM)
  * Create Users and Groups
    * gpg --gen-key
    * gpg --export "emailusedinkey-gen" > ./terraform/users/z.gpg.pub
    * `cd ./terraform/users/`
    * `terraform init`
    * `cp aws-build.tfvars.sample aws-build.tfvars`
    * `terraform apply -var-file="aws-build.tfvars" -auto-approve`

  * ttrpg user set-up
    * To get Console Password
      * `terraform output ttrpg_password | sed 's/"//g' | base64 -d | gpg -dq`
    * Create AWS Profile in ~/.aws/credentials or use `aws configure`
```
[ttrpg]
aws_access_key_id = <Access Key ID>
aws_secret_access_key = <Access Key Secret>
```

  * ttrpg-s3 user set-up
    * Add ttrpg_s3_access_key_id and ttrpg_s3_access_key_secret to server aws-build.tfvars
    * Create AWS Profile in ~/.aws/credentials or use `aws configure`
```
[ttrpg-s3]
aws_access_key_id = <Access Key ID>
aws_secret_access_key = <Access Key Secret>
```


## Create System Manager Parameter Store Values (Cloud ENV variables)
  * SSM 
      * Make sure you have the .env file at the root of this project filled out
      * `cd ./terraform/ssm/`
      * `terraform init`
      * `cp aws-build.tfvars.sample aws-build.tfvars`
      * `terraform apply -var-file="aws-build.tfvars" -auto-approve`

## Create a route53 domain and records (optional)
  * DNS (route53)
    * Register a Domain with route53 using the console with your main account login
      * [Route53](https://console.aws.amazon.com/route53/home#DomainListing:)
    * Leave the base Base Zone Record created

## Create a cert to use with Cloudfront
  * Certificate (ACM & Let's Encrypt)
    * DNS (route53)
      * `cd ./terraform/certificates/`
      * `terraform init`
      * `cp aws-build.tfvars.sample aws-build.tfvars`
      * `terraform apply -var-file="aws-build.tfvars" -auto-approve`

## Build Project
  * Build
    * `cd ./terraform/`
    * `terraform init`
    * `cp aws-build.tfvars.sample aws-build.tfvars`
    * `terraform apply -var-file="aws-build.tfvars" -auto-approve`

### aws-build.tfvars defined
Name | Value | Explanation
-----|-------|-------------
restore_from_local | true/false | Whether or not to use this local repo to seed s3
aws_region | AWS Region | Region services will be located
instance_type | Instance Type | [Instance Type](https://aws.amazon.com/ec2/instance-types/)
sshpath | /home/user/.ssh/ | Absolute Path to where your SSH keys are stored
private_key_name | some_ssh_private_keyname | Private SSH Key Name
public_key_name | some_ssh_public_keyname | Public SSH Key Name
git_user | git repo user | Your github repo user
aws_s3_access_key_id | ttrpg_s3_access_key_id | ttrpg-s3 Access Key ID
aws_s3_secret_access_key | ttrpg_s3_access_key_secret | ttrpg-s3 Access Secret Key
aws_dns_zone_id | ZAJHSK7867860 | Zone Id from route53 hosted zones record that matches the domain


## All Done! 


## How the individual modules work and run alone

  * Backup (s3)
    * Create s3 Bucket
      * `cd ./terraform/backup/`
      * `terraform init`
      * `cp aws-build.tfvars.sample aws-build.tfvars`
      * `terraform apply -var-file="aws-build.tfvars" -auto-approve`
    * Backup local files to s3
      * `aws --profile ttrpg-s3 s3 sync ~/ttrpg-tools/nginx/ssl/ s3://ttrpg-terraform-bucket/letsencrypt/`
      * `aws --profile ttrpg-s3 s3 sync ~/ttrpg-tools/mongo/data/ s3://ttrpg-terraform-bucket/mongo_data/` 
      * `aws --profile ttrpg-s3 s3 sync ~/ttrpg-tools/dungeon-revealer/data/ s3://ttrpg-terraform-bucket/dr_data/`
    * Restore local files to s3
      * `aws --profile ttrpg-s3 s3 sync s3://ttrpg-terraform-bucket/letsencrypt/ ./nginx/ssl/`
      * `aws --profile ttrpg-s3 s3 sync s3://ttrpg-terraform-bucket/mongo_data/ ./mongo/data/`
      * `aws --profile ttrpg-s3 s3 sync s3://ttrpg-terraform-bucket/dr_data/ ./dungeon-revealer/data/`
    * On the ec2 instance the commands are the same except `--profile ttrpg-s3` doesn't need to be declared.

  * Server (ec2,VPC)
    * Configure your local [.env file](https://github.com/wushin/ttrpg-tools#env-file-options)
    * Create ec2 instance, VPCs and Application LB
      * `cd ./terraform/server/`
      * `terraform init`
      * `cp aws-build.tfvars.sample aws-build.tfvars`
      * `terraform apply -var-file="aws-build.tfvars" -auto-approve`
      * Server should deploy and build the Docker containers as well
    * Outputs
      * aws_lb_dns_name is the public DNS at this point if you want.
      * public_ip is the public IP of the specific container you just built
        * Good host for SSH in on or you may use this as your DNS record as well.
    * To SSH into the container
      * `ssh -i <path to private ssh key> admin@<public_ip>`
    * The ec2 provides you with a complete build/dev environment
      * All the docker and make commands work like a local environment
        * See [Main Readme for details](https://github.com/wushin/ttrpg-tools/blob/main/README.md)
    * You can use the let's encrypt SSL method at this point. If you proceed, disable ssl in the .env file and rebuild.

### aws-build.tfvars defined
Name | Value | Explanation
-----|-------|-------------
aws_region | AWS Region | Region services will be located
instance_type | Instance Type | [Instance Type](https://aws.amazon.com/ec2/instance-types/)
sshpath | /home/user/.ssh/ | Absolute Path to where your SSH keys are stored
private_key_name | some_ssh_private_keyname | Private SSH Key Name
public_key_name | some_ssh_public_keyname | Public SSH Key Name
git_user | git repo user | Your github repo user
aws_s3_access_key_id | ttrpg_s3_access_key_id | ttrpg-s3 Access Key ID
aws_s3_secret_access_key | ttrpg_s3_access_key_secret | ttrpg-s3 Access Secret Key
      

  * Certificate (ACM & Let's Encrypt)
    * DNS (route53)
      * `cd ./terraform/certificates/`
      * `terraform init`
      * `cp aws-build.tfvars.sample aws-build.tfvars`
      * `terraform apply -var-file="aws-build.tfvars" -auto-approve`

### aws-build.tfvars defined
Name | Value | Explanation
-----|-------|-------------
domain_name | domain.org | Domain Name you have registered
domain_email | your@email.com | Recovery email for Let's Encrypt
aws_dns_zone_id | ZAJHSK7867860 | Zone Id from route53 hosted zones record that matches the domain


  * Cloudfront (Cloudfront) (optional)
    * Auto DNS (route53)
      * `cd ./terraform/cloudfront/`
      * `terraform init`
      * `cp aws-build.tfvars.sample aws-build.tfvars`
      * `terraform apply -var-file="aws-build.tfvars" -auto-approve`
      * cloudfront_dns result will automatically be added to your DNS for each host


### aws-build.tfvars defined
Name | Value | Explanation
-----|-------|-------------
aws_region | AWS Region | Region services will be located
domain_name | domain.org | Domain Name you have registered
aws_dns_zone_id | ZAJHSK7867860 | Zone Id from route53 hosted zones record that matches the domain
aws_lb_dns_name | aws_lb_dns_name | aws_lb_dns_name from outputs of server terraform
aws_lb_id | aws_lb_id | aws_lb_id from outputs of server terraform
acm_certificate_arn | acm_certificate_arn | acm_certificate_arn from outputs of certificate terraform

