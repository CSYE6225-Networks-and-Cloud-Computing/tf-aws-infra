data "aws_route53_zone" "main" {
  name         = var.demo_domain_name
  private_zone = false
}

resource "aws_route53_record" "webapp" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.demo_domain_name
  type    = "A"
  # ttl     = "300"
  # records = [aws_instance.web_app.public_ip]

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}