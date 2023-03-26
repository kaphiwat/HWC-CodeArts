terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
      version = "1.35.2"
    }
  }
}

provider "huaweicloud" {
  access_key = ""
  secret_key = ""
  region     = "ap-southeast-3"
}