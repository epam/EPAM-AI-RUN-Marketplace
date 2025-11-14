output "aice_neo4j_plugins_s3_bucket_name" {
  description = "Amazon S3 bucket name for remote Aice Neo4j plugins storage"
  value       = aws_s3_bucket.aice_neo4j_plugins.id
}
