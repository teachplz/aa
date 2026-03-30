# 🚨 AWS의 숨겨진 규칙: "DB를 만들려면 무조건 방(Subnet)이 2개 이상 필요해!"
# 만약 하나의 데이터센터에 불이 나면 다른 곳에서 살려야 하기 때문입니다.
# 그래서 아까 1단계에서 만든 프라이빗 서브넷(2c 구역)의 짝꿍으로, 
# 2a 구역에 프라이빗 방을 하나 더 만들어 줍니다.
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.bot_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a" # 아까는 2c, 이번엔 2a 구역

  tags = {
    Name = "bot-private-subnet-2"
  }
}

# 1. 데이터베이스 전용 '방 묶음(Subnet Group)' 만들기
resource "aws_db_subnet_group" "bot_db_subnet_group" {
  name       = "bot-db-subnet-group"
  # 아까 만든 1번 방과 방금 만든 2번 방을 하나로 묶어줍니다!
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "Bot DB Subnet Group"
  }
}

# 2. 드디어 진짜 일기장(MySQL 데이터베이스) 생성!
resource "aws_db_instance" "bot_db" {
  identifier           = "crypto-bot-db"
  allocated_storage    = 20               # 용량은 무료(프리티어)인 20GB
  engine               = "mysql"          # 데이터베이스 종류는 가장 유명한 MySQL
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"    # 서버 크기도 무료(프리티어) 사이즈
  
  db_name              = "botdiary"       # 일기장(데이터베이스) 이름
  username             = "admin"          # 접속 아이디
  password             = "Password1234!"  # 접속 비밀번호 (🚨 나중엔 금고에 숨겨야 합니다!)
  
  # 어떤 방 묶음에 넣을까? 👉 방금 만든 프라이빗 방 묶음!
  db_subnet_group_name   = aws_db_subnet_group.bot_db_subnet_group.name
  
  # 어떤 경비원을 세울까? 👉 2단계에서 만든 '로봇만 통과시키는' 깐깐한 경비원!
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # 연습용이므로 삭제할 때 백업본(스냅샷)을 안 남기고 깔끔하게 지워지도록 설정
  skip_final_snapshot  = true 
}