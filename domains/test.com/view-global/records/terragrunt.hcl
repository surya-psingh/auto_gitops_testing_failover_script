// This file is to handle the creation of records for Bind, Route53, Powerdns
locals {
  endpoints       = yamldecode(file("${get_parent_terragrunt_dir()}/config/dc_endpoints.yml"))
  zone_config     = read_terragrunt_config(find_in_parent_folders("zone_config.hcl"))
  domain_vars     = read_terragrunt_config( find_in_parent_folders( "domain.hcl" ) )
  view_vars       = read_terragrunt_config( find_in_parent_folders( "view.hcl" ) )
  type            = local.domain_vars.locals.type
  provider        = local.view_vars.locals.provider
  region          = local.view_vars.locals.region
  domain_records  = yamldecode(file("records.yml"))
  common_records  = try( yamldecode(file(find_in_parent_folders("view-template/records/records.yml"))), {})
}


include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:8x8/auto_hashicorp_terraform_modules_dns_records.git//?ref=master"
}

dependency "zone" {
  // Zone will export zone name and zone_id (if cloud)
  config_path = "../zone"
}

inputs = {
  domain_name     = dependency.zone.outputs.fqdn
  domain_type     = dependency.zone.outputs.zone_type
  topology        = dependency.zone.outputs.topology
  records_data    = merge( try(local.domain_records, {}), local.common_records)
  zone_id         = try( dependency.zone.outputs.zone_id, "" )
  provider_name   = dependency.zone.outputs.provider_name
  region_name     = dependency.zone.outputs.region_name
  ttl             = dependency.zone.outputs.zone_default_ttl_sec
}
