provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_subnet_a" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "example_subnet_b" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_security_group" "example_security_group" {
  name        = "example-security-group"
  description = "Example security group for Lambda function"
  vpc_id      = aws_vpc.example_vpc.id

  // Ingress rule allowing incoming traffic on port 443 (HTTPS) from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Ingress rule allowing incoming SSH traffic from a specific IP address range
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"] 
  }

  // Egress rule allowing all outgoing traffic to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "example_lambda" {
  filename         = "example_lambda.zip"
  function_name    = "example_lambda_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("example_lambda.zip")
  runtime          = "python3.8"

  vpc_config {
    subnet_ids         = [aws_subnet.example_subnet_a.id, aws_subnet.example_subnet_b.id]
    security_group_ids = [aws_security_group.example_security_group.id]
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}
