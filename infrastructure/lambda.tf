resource "aws_lambda_function" "processor" {
  function_name = "${var.project_name}-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "processor.lambda_handler"
  runtime       = var.lambda_runtime

  filename         = "../lambda/function.zip"
  source_code_hash = filebase64sha256("../lambda/function.zip")

  environment {
    variables = {
      RAW_BUCKET       = aws_s3_bucket.raw_data.bucket
      PROCESSED_BUCKET = aws_s3_bucket.processed_data.bucket
      DEST_BUCKET  =  aws_s3_bucket.processed_data.bucket
    }
  }
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda-s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Bucket-level permission
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.processed_data.arn
      },
      # Object-level permission
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.processed_data.arn}/*"
      }
    ]
  })
}
