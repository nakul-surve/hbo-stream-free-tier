output "videos_bucket_id" {
  value = aws_s3_bucket.videos.id
}

output "videos_bucket_arn" {
  value = aws_s3_bucket.videos.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.videos.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.videos.id
}
