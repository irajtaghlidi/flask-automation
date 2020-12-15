# Flash Hello-World deployment automation with Terraform in AWS.
This Terraform script use AWS credentials in your machine just for development, But the best practice is using encriptions like Vault to store credentials and keys in a secuire way.
The state files also should be store in remote state solutions like Terraform Cloud or using cloud storages like S3.

* In this demo we use a predefined Hosted Zone name, we can create a new one also but it takes more time to validate in my development time.


Please modify `terraform.tfvars` file before start. (It should be save securely always but in this demo repository we don't have any sensitive data in the file)

```
terraform init

terraform plan

terraform apply
```

* We can also use KMS to add more security in the infrastructure.


* After creat and running services, Wait until ECS deployment is complete. (there is no options in Terraform for this)
