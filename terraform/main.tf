module "web1" {
  source = "./web_deploy"

  image           = "${var.server_image}"
  replicas        = 3
  deployment_name = "web1"
}
module "web2" {
  source = "./web_deploy"

  image           = "${var.server_image}"
  replicas        = 3
  deployment_name = "web2"
}
