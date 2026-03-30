# 1. 로봇(EC2)을 위한 경비원 (방화벽)
resource "aws_security_group" "bot_sg" {
  name        = "crypto-bot-sg"
  description = "Security Group for Crypto Trading Bot EC2"
  vpc_id      = aws_vpc.bot_vpc.id # 아까 1단계에서 만든 우리 사유지(VPC)에 소속시킵니다.

  # 🚪 인바운드 (들어오는 문): 집주인(질문자님) 전용 도어락
  ingress {
    description = "SSH access for Admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # 🚨 주의: 연습용이라 일단 다 열어두지만(0.0.0.0/0), 
    # 실무에서는 "내 집 IP/32" (예: 123.45.67.89/32)로 깐깐하게 막아야 합니다!
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # 🚀 아웃바운드 (나가는 문): 로봇이 업비트로 시세 보러 나가는 출구
  egress {
    description = "Allow all outbound traffic for Bot"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # '-1'은 모든 방식(TCP, UDP 등)을 다 허용한다는 뜻입니다.
    cidr_blocks = ["0.0.0.0/0"] # 목적지 상관없이 어디든 나갈 수 있게 활짝 엽니다!
  }

  tags = {
    Name = "bot-ec2-sg"
  }
}

# 2. 일기장(데이터베이스)을 위한 경비원 (방화벽)
resource "aws_security_group" "db_sg" {
  name        = "crypto-db-sg"
  description = "Security Group for Crypto Database"
  vpc_id      = aws_vpc.bot_vpc.id

  # 🔒 데이터베이스 인바운드: "오직 우리 로봇(bot_sg)만 들어올 수 있어!"
  ingress {
    description     = "Allow MySQL traffic ONLY from Bot EC2"
    from_port       = 3306 # MySQL 데이터베이스 전용 문
    to_port         = 3306
    protocol        = "tcp"
    
    # ★ 핵심 기술: IP 주소가 아니라 '로봇의 방화벽(bot_sg)'을 통과한 애들만 허락합니다!
    security_groups = [aws_security_group.bot_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bot-db-sg"
  }
}