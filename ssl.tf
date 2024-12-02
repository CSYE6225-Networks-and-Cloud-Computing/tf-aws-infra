# # dev SSL certificate
# resource "aws_acm_certificate" "dev_cert" {
#   count             = var.environment == "dev" ? 1 : 0
#   domain_name       = var.dev_domain_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # DNS validation record
# resource "aws_route53_record" "cert_validation" {
#   count   = var.environment == "dev" ? 1 : 0
#   name    = tolist(aws_acm_certificate.dev_cert[0].domain_validation_options)[0].resource_record_name
#   type    = tolist(aws_acm_certificate.dev_cert[0].domain_validation_options)[0].resource_record_type
#   zone_id = data.aws_route53_zone.main.zone_id
#   records = [tolist(aws_acm_certificate.dev_cert[0].domain_validation_options)[0].resource_record_value]
#   ttl     = 60
# }

# resource "aws_acm_certificate_validation" "dev_cert" {
#   count                   = var.environment == "dev" ? 1 : 0
#   certificate_arn         = aws_acm_certificate.dev_cert[0].arn
#   validation_record_fqdns = [aws_route53_record.cert_validation[0].fqdn]
# }

# demo SSL certificate
data "aws_acm_certificate" "ssl_certificate" {
  domain      = var.demo_domain_name
  most_recent = true
  statuses    = ["ISSUED"]

}

resource "aws_lb_listener" "my_https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ssl_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

}


## SSL Certificate Import
# ```bash
# aws acm import-certificate \
#     --certificate fileb://certificate.pem \
#     --private-key fileb://privateKey.pem \
#     --certificate-chain fileb://certificateChain.pem \
#     --region us-east-1