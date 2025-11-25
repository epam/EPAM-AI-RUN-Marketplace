data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "aice_neo4j_plugins" {
  bucket = "${var.s3_states_bucket_name}-${data.aws_caller_identity.current.account_id}"

  tags = merge(tomap({ "Name" = var.s3_states_bucket_name }), var.tags)
}


resource "aws_s3_object" "dozerdb_plugin_object" {
    bucket = aws_s3_bucket.aice_neo4j_plugins.bucket
    key    = "plugins/dozerdb-plugin-5.26.3.0.jar"
    source = "./plugins/dozerdb-plugin-5.26.3.0.jar"
}

resource "aws_s3_object" "apoc_object" {
    bucket = aws_s3_bucket.aice_neo4j_plugins.bucket
    key    = "plugins/apoc-5.26.3-core.jar"
    source = "./plugins/apoc-5.26.3-core.jar"
}

resource "aws_s3_object" "neo4j_graph_data_science_object" {
    bucket = aws_s3_bucket.aice_neo4j_plugins.bucket
    key    = "plugins/neo4j-graph-data-science-2.13.4.jar"
    source = "./plugins/neo4j-graph-data-science-2.13.4.jar"
}

resource "aws_s3_bucket_policy" "aice_neo4j_plugins" {
  bucket = aws_s3_bucket.aice_neo4j_plugins.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.platform_name}-on-demand-node-group",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.platform_name}-spot-node-group"
        ]
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
          "${aws_s3_bucket.aice_neo4j_plugins.arn}",
        "${aws_s3_bucket.aice_neo4j_plugins.arn}/*"
      ]
    }
  ]
}
POLICY
}