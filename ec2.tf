# 1. 로봇을 위한 AWS 신분증(IAM 역할) 만들기
resource "aws_iam_role" "bot_role" {
  name = "crypto-bot-ec2-role"

  # "이 신분증은 EC2(서버)라는 서비스만 찰 수 있습니다" 라는 규칙
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. 신분증에 '비밀 금고 열람 권한' 도장 찍어주기
resource "aws_iam_role_policy_attachment" "bot_ssm_policy" {
  role       = aws_iam_role.bot_role.name
  # AWS가 미리 만들어둔 'Parameter Store(금고) 접근 및 서버 관리 권한' 입니다.
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. 신분증을 담을 '목걸이(Instance Profile)' 만들기
# (EC2 서버에 신분증을 걸어주려면 이 목걸이 형태가 꼭 필요합니다!)
resource "aws_iam_instance_profile" "bot_profile" {
  name = "crypto-bot-profile"
  role = aws_iam_role.bot_role.name
}

# 4. 드디어 로봇의 심장! (EC2 서버 생성)
resource "aws_instance" "trading_bot" {
  ami           = "ami-0ecfdfd1c8ae01aec" # 아까 쓰셨던 Amazon Linux 2023 이미지
  instance_type = "t3.micro"

  # 어느 방에 넣을까? 👉 1단계에서 만든 인터넷 빵빵한 퍼블릭 서브넷!
  subnet_id     = aws_subnet.public_subnet.id

  # 어떤 경비원을 세울까? 👉 2단계에서 만든 로봇 전용 방화벽!
  vpc_security_group_ids = [aws_security_group.bot_sg.id]

  # 어떤 신분증을 목에 걸어줄까? 👉 방금 만든 금고 출입증!
  iam_instance_profile = aws_iam_instance_profile.bot_profile.name

  tags = {
    Name = "Auto-Trading-Bot-Server"
  }
}