data "aws_route53_zone" "main" {
  name         = var.dev_domain_name
  private_zone = false
}

resource "aws_route53_record" "webapp" {
  zone_id = var.dev_route53_zone_id
  name    = var.dev_domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web_app.public_ip]
}