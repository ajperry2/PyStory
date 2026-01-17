# Cognito User Pool for authentication
resource "aws_cognito_user_pool" "pystory" {
  name = "pystory-user-pool"

  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    required           = true
    mutable            = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  tags = {
    Name        = "PyStory User Pool"
    Environment = var.environment
    Project     = "PyStory"
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "pystory" {
  name         = "pystory-app-client"
  user_pool_id = aws_cognito_user_pool.pystory.id

  generate_secret = false

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  supported_identity_providers = ["COGNITO", "Google"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "pystory" {
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.pystory.id
}

# Google Identity Provider
resource "aws_cognito_identity_provider" "google" {
  count = var.google_client_id != "" ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.pystory.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "profile email openid"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    name     = "name"
    picture  = "picture"
  }
}

# Cognito Identity Pool for AWS resource access
resource "aws_cognito_identity_pool" "pystory" {
  identity_pool_name               = "pystory_identity_pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.pystory.id
    provider_name           = aws_cognito_user_pool.pystory.endpoint
    server_side_token_check = false
  }

  dynamic "cognito_identity_providers" {
    for_each = var.google_client_id != "" ? [1] : []
    content {
      client_id               = var.google_client_id
      provider_name           = "accounts.google.com"
      server_side_token_check = false
    }
  }
}

# IAM role for authenticated Cognito users
resource "aws_iam_role" "cognito_authenticated" {
  name = "pystory-cognito-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.pystory.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "PyStory Cognito Authenticated Role"
    Environment = var.environment
    Project     = "PyStory"
  }
}

# IAM policy for authenticated users to access S3 and DynamoDB
resource "aws_iam_role_policy" "cognito_authenticated_policy" {
  name = "cognito-authenticated-policy"
  role = aws_iam_role.cognito_authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.story_media.arn}/users/$${cognito-identity.amazonaws.com:sub}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.books.arn,
          "${aws_dynamodb_table.books.arn}/index/*"
        ]
      }
    ]
  })
}

# Attach identity pool roles
resource "aws_cognito_identity_pool_roles_attachment" "pystory" {
  identity_pool_id = aws_cognito_identity_pool.pystory.id

  roles = {
    authenticated = aws_iam_role.cognito_authenticated.arn
  }
}
