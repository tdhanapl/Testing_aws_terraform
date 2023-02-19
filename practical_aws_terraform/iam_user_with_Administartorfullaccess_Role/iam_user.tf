provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_policy" "administrator_full_access" {
  name        = "administrator_full_access"
  description = "Full access to all AWS services"

  policy = file("administrator_full_access_policy.json")
}

## creating user 
resource "aws_iam_user" "user_one" {
  name = var.user
}
resource "aws_iam_user_policy_attachment" "example_user_administrator_full_access" {
  user       = aws_iam_user.user_one.name
  policy_arn = aws_iam_policy.administrator_full_access.arn
}


