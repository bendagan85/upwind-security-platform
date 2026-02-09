# iam-github.tf

# 1. שליפה דינמית של תעודת האבטחה של גיטהאב (מונע בעיות של Thumbprint לא מעודכן)
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# 2. הגדרת ה-Identity Provider עם החתימה שנשלפה אוטומטית
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# 3. ה-Role עצמו עם הרשאות הגישה
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          # בדיקה 1: שהבקשה מגיעה מהריפו שלך ספציפית
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:bendagan85/upwind-security-platform:*"
          }
          # בדיקה 2: שהטוקן מיועד ל-AWS (חשוב מאוד!)
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

