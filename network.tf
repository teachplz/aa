# 1. 튼튼한 외곽 울타리 (VPC)
resource "aws_vpc" "bot_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # 로봇이 인터넷 도메인(upbit.com 등)을 찾을 수 있게 해줍니다.
  enable_dns_hostnames = true

  tags = {
    Name = "crypto-bot-vpc"
  }
}

# 2. 로봇이 뛰어놀 접견실 (퍼블릭 서브넷)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.bot_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a" # 서울 리전의 a구역
  map_public_ip_on_launch = true # 이 방에 들어오는 서버는 자동으로 공인 IP(인터넷 주소)를 받습니다.

  tags = {
    Name = "bot-public-subnet"
  }
}

# 3. 소중한 일기장을 숨겨둘 비밀 금고실 (프라이빗 서브넷)
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.bot_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c" # 서울 리전의 c구역 (보통 DB는 다른 구역에 두는 것이 안전합니다)

  tags = {
    Name = "bot-private-subnet"
  }
}

# 4. 외부로 나가는 대문 (인터넷 게이트웨이)
resource "aws_internet_gateway" "bot_igw" {
  vpc_id = aws_vpc.bot_vpc.id

  tags = {
    Name = "bot-igw"
  }
}

# 5. 로봇에게 대문으로 가는 길을 알려주는 지도 (라우팅 테이블)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.bot_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # 목적지가 어디든 간에 (업비트든 바이낸스든)
    gateway_id = aws_internet_gateway.bot_igw.id # 우리가 만든 대문(IGW)으로 나가라!
  }

  tags = {
    Name = "bot-public-rt"
  }
}

# 6. 접견실(퍼블릭 서브넷) 벽에 지도(라우팅 테이블) 걸어두기
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}