# Configure the AWS Provider
provider "aws" {
    version    = "~> 3.21.0"
    region     = var.region
}


resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 5000
    to_port         = 5000
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Create IAM Role for ECS Execution
data "aws_iam_policy_document" "ecs_task_execution_role" {
    version = "2012-10-17"
    statement {
        sid     = ""
        effect  = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name               = "ecs-flask-execution-role"
    assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Create Task Definitions
data "template_file" "app" {
    template = file("./app.json.tpl")
    vars = {
        aws_ecr_repository = var.repo_url
        tag                = var.repo_tag
        app_port           = 80
    }
}


resource "aws_ecs_task_definition" "service" {
  family                   = "app"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.app.rendered
  tags = {
    Application = "Flask"
  }
}


# Create ECS Cluster
resource "aws_ecs_cluster" "app" {
  name = "tf-ecs-cluster"
}


# Create ECS Service
resource "aws_ecs_service" "flask" {
    name            = "flask"
    cluster         = aws_ecs_cluster.app.id
    task_definition = aws_ecs_task_definition.service.arn
    desired_count   = 1
    launch_type     = "FARGATE"

    network_configuration {
        security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = aws_subnet.app.*.id
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.app.arn
        container_name   = "app"
        container_port   = 5000
    }

    depends_on = [aws_lb_listener.https, aws_lb_listener.http_redirect, aws_iam_role_policy_attachment.ecs_task_execution_role]

    tags = {
        Application = "Flask"
    }
}



# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name = "awslogs-app-flask"

  tags = {
    Application = "Flask"
  }
}



# Output app address
output "app_address" {
    value       = "https://${var.domain_name}"
    description = "Open this URL in browser"
}