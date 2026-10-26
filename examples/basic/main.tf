provider "volcenginecc" {
  region = var.region
}

module "mongodb" {
  source  = "terraform-volcenginecc-modules/mongodb/volcenginecc"
  version = "~> 1.0"

  instance_name    = var.instance_name
  vpc_id           = var.vpc_id
  subnet_id        = var.subnet_id
  zone_ids         = [var.zone_id]
  node_spec        = var.node_spec
  storage_space_gb = var.storage_space_gb
  root_password    = var.root_password

  allow_lists = {
    application = {
      name         = "${var.instance_name}-application"
      description  = "Trusted application subnet for private MongoDB access"
      ip_addresses = var.application_cidrs
    }
  }

  tags = {
    Environment = "example"
    Scenario    = "document-store"
  }
}
