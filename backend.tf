terraform  {
    backend "s3" {
        bucket  =   "aaavva11fqq"
        key     =   "terraform/state/terraform.tfstate"
        region   = "ap-northeast-2"
    }
}