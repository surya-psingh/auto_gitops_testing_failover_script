locals {
  endpoints    = yamldecode(file("${get_parent_terragrunt_dir()}/config/dc_endpoints.yml"))
  zone_config  = read_terragrunt_config(find_in_parent_folders("zone_config.hcl"))
  d_vars       = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  v_vars       = read_terragrunt_config(find_in_parent_folders("view.hcl"))
  region       = local.v_vars.locals.region
  provider     = local.v_vars.locals.provider
  view         = local.v_vars.locals.type
  domain       = local.d_vars.locals.domain
  public_zone  = local.d_vars.locals.public_zone
  type         = local.d_vars.locals.type
  name_servers = try( length( local.d_vars.locals.ns ) > 0 ? local.d_vars.locals.ns : local.endpoints[ local.region ][ local.provider ][ "ns" ], {} )
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "/Users/mlaws/Working/source/dns/auto_hashicorp_terraform_modules_dns_zone//"
  //source = "git@github.com:8x8/auto_hashicorp_terraform_modules_dns_zone.git//?ref=master"
}

/*
PARENT DOMAIN INHERITANCE
NOTE: Commented-out as a root zone has no parent domain

dependency "parent_domain" {
  // Parent domain will export fqdn, region, provider, and zone_id (if cloud)
  config_path = "../../../../zone"
}
*/

inputs = {
  // General domain configuration
  domain_name                       = local.domain
  domain_type                       = local.type
  provider_name                     = local.provider
  region_name                       = local.region
  name_servers                      = local.name_servers
  render_zone                       = local.view == "operational" ? true : false
  // Configuration required for Bind zones
  destroy_protection                = local.d_vars.locals.destroy_protection
  public_zone                       = local.d_vars.locals.public_zone
  topology                          = local.d_vars.locals.topology
  acl                               = local.d_vars.locals.acl
  also_notify                       = local.d_vars.locals.also_notify
  allow_transfer                    = local.d_vars.locals.allow_transfer
  allow_update                      = local.d_vars.locals.allow_update
  vault_mount_point                 = local.d_vars.locals.vault_mount
  dynamic_keys                      = local.d_vars.locals.dynamic_keys
  zone_admin_email                  = local.zone_config.locals.zone_admin_email
  timer_zone_default_ttl_sec        = local.zone_config.locals.zone_default_ttl_sec
  timer_zone_soa_ttl_sec            = local.zone_config.locals.zone_soa_ttl_sec
  timer_zone_refresh_sec            = local.zone_config.locals.zone_refresh_sec
  timer_zone_retry_sec              = local.zone_config.locals.zone_retry_sec
  timer_zone_expire_sec             = local.zone_config.locals.zone_expire_sec
  timer_zone_negative_cache_sec     = local.zone_config.locals.zone_negative_cache_sec
  timer_delegation_ttl_sec          = local.zone_config.locals.delegation_ttl_sec
  // Configuration valid only for subdomains
  // parent_domain_name                = dependency.parent_domain.outputs.fqdn
  // parent_domain_type                = dependency.parent_domain.outputs.zone_type
  // parent_provider_name              = dependency.parent_domain.outputs.provider_name
  // parent_region_name                = dependency.parent_domain.outputs.region_name
  // parent_topology                   = try( dependency.parent_domain.outputs.topology, {} )
  // parent_bind_delegations_file_path = try( dependency.parent_domain.outputs.bind_delegations_file_path, "" )
  // parent_zone_id                    = try( dependency.parent_domain.outputs.zone_id, "" )
}
