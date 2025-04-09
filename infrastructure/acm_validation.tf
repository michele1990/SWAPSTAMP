resource "aws_route53_record" "cert_validation_apex" {
  zone_id = "Z08092634J9RRKFDFVCG"  # your known hosted zone ID
  name    = "_8f940b893bd23c3bfda9a1cf1ab79b28.swapstamp.com"
  type    = "CNAME"
  records = ["_c4eb5c1cbec0c516c8497523957e10fa.xlfgrmvvlj.acm-validations.aws."]
  ttl     = 60

  # In case the record already exists, ignore changes
  lifecycle {
    ignore_changes = [records]
  }
}

resource "aws_route53_record" "cert_validation_www" {
  zone_id = "Z08092634J9RRKFDFVCG"
  name    = "_6c61d250d5618b79bf3834b830931c97.www.swapstamp.com"
  type    = "CNAME"
  records = ["_5d0e78264be552383b02ef19c4254aa8.xlfgrmvvlj.acm-validations.aws."]
  ttl     = 60

  lifecycle {
    ignore_changes = [records]
  }
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [
    aws_route53_record.cert_validation_apex.fqdn,
    aws_route53_record.cert_validation_www.fqdn
  ]
}
