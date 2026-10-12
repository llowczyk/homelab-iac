locals {
  common_tags = ["iac", "linux", "virtual-machine"]

  vm_tags = {
    monitoring  = sort(concat(local.common_tags, ["cctv"]))
    torrentbox  = sort(concat(local.common_tags, ["p2p"]))
    mediaserver = sort(concat(local.common_tags, ["arr-stack", "media"]))
    proxy       = sort(concat(local.common_tags, ["network", "proxy"]))
    tools       = sort(concat(local.common_tags, ["observability"]))
    nas         = sort(concat(local.common_tags, ["nfs", "samba"]))
    jumpbox     = sort(concat(local.common_tags, ["jumphost", "tailscale"]))
    gameserver  = sort(concat(local.common_tags, ["games"]))
  }
}
