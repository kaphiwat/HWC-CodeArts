resource "huaweicloud_swr_organization" "org" {
   name = "apac_devops_swr"
}

resource "huaweicloud_swr_repository_sharing" "swr1" {
  organization    = huaweicloud_swr_organization.org.id
  repository      = "app-demo-ga"
  sharing_account = "prod-account"
  permission      = "pull"
  deadline        = "forever"
}

resource "huaweicloud_swr_repository_sharing" "swr2" {
  organization    = huaweicloud_swr_organization.org.id
  repository      = "app-demo-build"
  sharing_account = "sit-account"
  permission      = "pull"
  deadline        = "forever"
}