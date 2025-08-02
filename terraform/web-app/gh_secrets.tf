data "github_repository" "current" {
  name = var.repository_name
}

resource "github_actions_secret" "cloudfront_distribution_id" {
  repository      = data.github_repository.current.name
  secret_name     = var.environment == "live" ? "LIVE_CLOUDFRONT_DISTRIBUTION_ID" : "TEST_CLOUDFRONT_DISTRIBUTION_ID"
  plaintext_value = aws_cloudfront_distribution.web_application.id
}

resource "github_actions_secret" "cloudfront_distribution_domain_name" {
  repository      = data.github_repository.current.name
  secret_name     = var.environment == "live" ? "LIVE_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME" : "TEST_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME"
  plaintext_value = aws_cloudfront_distribution.web_application.domain_name
}