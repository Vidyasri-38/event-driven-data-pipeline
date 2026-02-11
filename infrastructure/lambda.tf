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
    }
  }
}


