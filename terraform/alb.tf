# Create Security Groups
resource "aws_security_group" "lb" {
    name        = "lb-sg"
    description = "controls access to the Application Load Balancer (ALB)"
    vpc_id      = aws_vpc.app_vpc.id

    ingress {
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create Application Load Balancer
resource "aws_lb" "app" {
    name               = "app-alb"
    subnets            = aws_subnet.app.*.id
    load_balancer_type = "application"
    security_groups    = [aws_security_group.lb.id]

    tags = {
        Application = "Flask"
    }
}


resource "aws_lb_target_group" "app" {
    name        = "app-alb-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.app_vpc.id
    target_type = "ip"

    health_check {
        healthy_threshold   = "3"
        interval            = "90"
        protocol            = "HTTP"
        matcher             = "200-299"
        timeout             = "20"
        path                = "/"
        unhealthy_threshold = "2"
    }
}


resource "aws_lb_listener" "http_redirect" {
    load_balancer_arn = aws_lb.app.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}


resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.app.arn
    port              = "443"
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = aws_acm_certificate_validation.app.certificate_arn

    default_action { 
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
    }
}


resource "aws_route53_record" "app_lb" {
    zone_id = data.aws_route53_zone.root_zone.zone_id
    name    = var.domain_name
    type    = "A"

    alias {
        name                   = aws_lb.app.dns_name
        zone_id                = aws_lb.app.zone_id
        evaluate_target_health = true
    }
}