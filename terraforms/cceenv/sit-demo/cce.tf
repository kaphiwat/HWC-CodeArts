# Create a CCE cluster
resource "huaweicloud_cce_cluster" "cce" {
  name                   = "sit-cluster"
  flavor_id              = "cce.s2.small"
  vpc_id                 = huaweicloud_vpc.vpc.id
  subnet_id              = huaweicloud_vpc_subnet.subnet1.id
  eip                    = huaweicloud_vpc_eip.eip.address
  cluster_version        = "v1.19"
  multi_az               = false
  container_network_type = "overlay_l2"
}

# Create a nodepool in CCE cluster
resource "huaweicloud_cce_node_pool" "node_pool" {
  cluster_id         = huaweicloud_cce_cluster.cce.id
  name               = "cce-foo-nodes-pool"
  flavor_id          = "c6s.large.2"
  os                 = "CentOS 7.6"
  initial_node_count = 2
  scall_enable       = true
  min_node_count     = 2
  max_node_count     = 10
  scale_down_cooldown_time = 100
  priority              = 1
  type                  = "vm"
  password              = ""

  root_volume {
    size       = 40
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }
}

# Create EIP for cluster and node
resource "huaweicloud_vpc_eip" "eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "cce-bandwidth"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}
