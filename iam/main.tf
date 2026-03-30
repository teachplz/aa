# 1. AWS 연결 설정
provider "aws" {
  region = "ap-northeast-2"
}

# 2. IAM 그룹 생성 (test_group)
resource "aws_iam_group" "test_group" {
  name = "test_group"
}

# 3. IAM 사용자 생성 (tom)
resource "aws_iam_user" "tom" {
  name          = "tom"
  force_destroy = true # 나중에 실습 끝나고 삭제할 때 에러 안 나게 강제 삭제 허용
}

# 4. 생성한 사용자(tom)를 그룹(test_group)에 포함시키기
resource "aws_iam_user_group_membership" "tom_membership" {
  user = aws_iam_user.tom.name
  groups = [
    aws_iam_group.test_group.name
  ]
}

# 5. 그룹에 'S3 읽기 전용' 권한(정책) 연결하기
resource "aws_iam_group_policy_attachment" "s3_read_only" {
  group      = aws_iam_group.test_group.name
  # AWS가 미리 만들어둔 S3 읽기 전용 정책의 고유 주소(ARN)입니다.
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# 6. 사용자 패스워드 설정 (AWS 콘솔 로그인용)
resource "aws_iam_user_login_profile" "tom_login" {
  user                    = aws_iam_user.tom.name
  password_reset_required = true  # 보안을 위해 첫 로그인 시 반드시 비밀번호를 바꾸도록 설정!
}

# 7. Output으로 결과 확인하기
output "created_user_name" {
  value       = aws_iam_user.tom.name
  description = "생성된 사용자 이름"
}

output "created_group_name" {
  value       = aws_iam_group.test_group.name
  description = "생성된 그룹 이름"
}

output "tom_initial_password" {
  value       = aws_iam_user_login_profile.tom_login.password
  description = "Tom의 초기 임시 비밀번호"
  sensitive   = true   # ★ 테라폼에게 "이거 비밀번호 맞으니까 알아서 잘 가려줘" 라고 허락하는 옵션!
}