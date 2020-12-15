region             = "eu-central-1"
vpc_prefix         = "10.1.0.0/16"
subnet_prefix      = ["10.1.1.0/24", "10.1.2.0/24"]
availability_zones = ["eu-central-1a", "eu-central-1b"]

zone_name           = "iraj.pro"
domain_name         = "app.iraj.pro"

repo_url = "public.ecr.aws/e3i0m2n3/flask-app"
repo_tag = "latest"
