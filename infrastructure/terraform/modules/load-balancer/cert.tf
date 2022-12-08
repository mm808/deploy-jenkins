resource "aws_acm_certificate" "jenkins_cert" {
  domain_name       = "jenkins.${var.env}.astech.com"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "env_zone" {
  name         = "${var.env}.astech.com"
  private_zone = false
}

resource "aws_route53_record" "jenkins_record" {
  for_each = {
    for dvo in aws_acm_certificate.jenkins_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.env_zone.zone_id
}

resource "aws_acm_certificate_validation" "jenkins_cert" {
  certificate_arn         = aws_acm_certificate.jenkins_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.jenkins_record : record.fqdn]
}
