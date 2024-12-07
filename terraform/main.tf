# Referencing front-end module
module "front-end" {
  source = "./modules/front-end"
}

# Referencing back-end module
module "back-end" {
  source = "./modules/back-end"
}

# Referencing monitoring module
module "monitoring" {
  source = "./modules/monitoring"
}