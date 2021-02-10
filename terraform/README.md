
Terraform and AWS Build
=======================

* AWS main account
  * My Security Creditials
    * Create Access Keys
    * Create AWS Profile in ~/.aws/credentials
```
[ttrpg-root]
aws_access_key_id = <Access Key ID>
aws_secret_access_key = <Access Key Secret>
```

* Users (IAM)
  * PGP Key
    * gpg --gen-key
    * gpg --export "emailusedinkey-gen" > z.gpg.pub
  * ttrpg
    * Console Password
      * terraform output ttrpg_password | sed 's/"//g' | base64 -d | gpg -dq
    * Create AWS Profile in ~/.aws/credentials
```
[ttrpg]
aws_access_key_id = <Access Key ID>
aws_secret_access_key = <Access Key Secret>
```

  * ttrpg-s3
    * Add ttrpg_s3_access_key_id and ttrpg_s3_access_key_secret to server aws-build.tfvars

* Backup (s3)
  * Create
  * Backup
  * Restore
* Server (ec2,VPC)
  * Make
  * SSH
  * Docker
* DNS (route53)
  * Register
  * Create Base Zone
* Certificate (ACM)
  * DNS (route53)
  * Email (Suggested for non-route53 domains)
* Cloudfront (Cloudfront)
  * Auto DNS (route53)
  * Manual DNS (Suggested for non-route53 domains)
