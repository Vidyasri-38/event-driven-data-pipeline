resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.project_name}-raw-data-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "processed_data" {
  bucket = "${var.project_name}-processed-data-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_versioning" "raw_versioning" {
  bucket = aws_s3_bucket.raw_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "processed_versioning" {
  bucket = aws_s3_bucket.processed_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
