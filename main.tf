locals {
  create_nlb = "${var.alb_type == "network" ? true : false}"
}

resource "aws_alb" "main" {
  count = "${var.create_alb ? 1 : 0}"

  name    = "${var.alb_name}"
  subnets = ["${var.subnets}"]

  # security_groups    = ["${var.alb_security_groups}"]
  internal           = "${var.alb_is_internal}"
  tags               = "${merge(var.tags, map("Name", var.alb_name))}"
  load_balancer_type = "${var.alb_type}"

  access_logs {
    bucket  = "${var.log_bucket_name}"
    prefix  = "${var.log_location_prefix}"
    enabled = "${var.enable_logging}"
  }

  depends_on = ["aws_s3_bucket.log_bucket"]
}

resource "aws_s3_bucket" "log_bucket" {
  count         = "${var.create_log_bucket && var.create_alb ? 1 : 0}"
  bucket        = "${var.log_bucket_name}"
  policy        = "${var.bucket_policy == "" ? data.aws_iam_policy_document.bucket_policy.json : var.bucket_policy}"
  force_destroy = "${var.force_destroy_log_bucket}"
  tags          = "${merge(var.tags, map("Name", var.log_bucket_name))}"
}

resource "aws_alb_target_group" "application_target_group" {
  count                = "${var.create_alb && !local.create_nlb ? 1 : 0}"
  name                 = "${var.alb_name}-tg"
  port                 = "${var.backend_port}"
  protocol             = "${upper(var.backend_protocol)}"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    interval            = "${var.health_check_interval}"
    path                = "${var.health_check_path}"
    port                = "${var.health_check_port}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    protocol            = "${var.backend_protocol}"
    matcher             = "${var.health_check_matcher}"
  }

  target_type = "${var.target_type}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${var.cookie_duration}"
    enabled         = "${ var.cookie_duration == 1 ? false : true}"
  }

  tags = "${merge(var.tags, map("Name", "${var.alb_name}-tg"))}"

  depends_on = ["aws_alb.main"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group" "network_target_group" {
  count                = "${var.create_alb && local.create_nlb ? 1 : 0}"
  name                 = "${var.alb_name}-tg"
  port                 = "${var.alb_tcp_port}"
  protocol             = "TCP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    interval            = "${var.health_check_interval}"
    port                = "${var.health_check_port}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
  }

  target_type = "${var.target_type}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${var.cookie_duration}"
    enabled         = "${ var.cookie_duration == 1 ? false : true}"
  }

  tags = "${merge(var.tags, map("Name", "${var.alb_name}-tg"))}"

  depends_on = ["aws_alb.main"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "frontend_http" {
  count             = "${contains(var.alb_protocols, "HTTP") && var.create_alb && ! local.create_nlb ? 1 : 0}"
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "${var.alb_http_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.application_target_group.id}"
    type             = "forward"
  }

  depends_on = ["aws_alb.main"]
}

resource "aws_alb_listener" "frontend_https" {
  count             = "${contains(var.alb_protocols, "HTTPS") && var.create_alb && ! local.create_nlb ? 1 : 0}"
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "${var.alb_https_port}"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"
  ssl_policy        = "${var.security_policy}"

  default_action {
    target_group_arn = "${aws_alb_target_group.application_target_group.id}"
    type             = "forward"
  }

  depends_on = ["aws_alb.main"]
}

resource "aws_alb_listener" "tcp_listener" {
  count             = "${var.create_alb && local.create_nlb ? 1 : 0}"
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "${var.alb_tcp_port}"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.network_target_group.id}"
    type             = "forward"
  }

  depends_on = ["aws_alb.main"]
}
