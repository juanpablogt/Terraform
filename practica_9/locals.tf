locals {
  sufix = "${var.tags["project"]}-${var.tags["region"]}-${var.tags["env"]}"
}

resource "random_string" "random" {
  length  = 8
  upper   = false
  special = false
}

locals {
  s3-sufix = lower(replace("${local.sufix}-${random_string.random.result}", "_", "-"))
}