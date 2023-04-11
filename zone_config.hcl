// Global DNS zone SOA configuration
//    Can be overridden at the domain/subdomain level by placing a
//    zone_config.hcl file in the same directory as domain.hcl.
locals {
  zone_admin_email        = "hostmaster@8x8.com"
  zone_default_ttl_sec    = 900
  zone_soa_ttl_sec        = 3600
  zone_refresh_sec        = 43200
  zone_retry_sec          = 7200
  zone_expire_sec         = 1209600
  zone_negative_cache_sec = 900
  delegation_ttl_sec      = 900
}
