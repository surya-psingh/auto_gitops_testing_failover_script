locals {
  // General domain configuration
  // ----------------------------
  // The "domain" variable is the domain or subdomain name.  For subdomains, do not
  // include the fully-qualified domain name, only the subdomain name.
  domain = "external"

  // The "type" variable represents the domain type, as defined in the 8x8 DNS
  // documentation.  This is used to determine the features and interfaces available
  // for managing the domain.  (e.g. "static", "dynamic", "api-managed", "out-of-tree")
  type = "out-of-tree"

  // The "ns" variable is a dictionary of authoritative name servers and IPs to which this
  // subdomain should be delegated in the parent domain.  This should be used for domains
  // delegated to servers other than Route53.  Route53 will choose the list of DNS servers
  // at zone creation time, so therefore they cannot be known ahead of time, in which
  // case "ns" should be an empty list.  The exception is for Route53 zones hosted
  // outside of this tree (type = "out-of-tree"), in which case the zone should be created
  // first, then the Route53-provided name servers can be add here.
  ns = {
    "ns-770.awsdns-32.net" = "",
    "ns-1683.awsdns-18.co.uk" = "",
    "ns-1067.awsdns-05.org" = "",
    "ns-401.awsdns-50.com" = ""
  }

  // Bind-specific zone configuration options
  // ----------------------------------------
  // Safety net to prevent domains hosted in Bind from being inadvertently destroyed
  destroy_protection = true

  // Configure the domain "visibility".  For Bind, this determines the view with which
  // the domain should be associated.
  public_zone = false

  // The "allow_transfer" variable is a list of IP addresses that are allowed to perform a
  // zone transfer of this zone/domain.  All zone masters and slaves are added to this list
  // by default.
  allow_transfer = []

  // The "also_notify" variable list a list of IP addresses to be notfied when this zone
  // is updated/changed.
  also_notify = []

  // Dyanmic update configuration options (for domains of type "dynamic")
  // The "vault_mount" variable is the top level of the Vault secrets path
  vault_mount = "team_sys_ops_us/secret"

  // The list of vault paths to Bind keys allowed to perform a dynamic DNS update
  dynamic_keys = []

  // List of IP addresses or subnets allowed to perform dynamic DNS updates
  allow_update = []

  // Topology for this zone (defines the relationship between Bind servers hosting this
  // zone/domain, and their roles.  Each is a list of IP addresses.
  topology = {
    master = [],
    slave = []
  }

  // IP access list to allow direct queries to this domain.  This will be replicated to all
  // servers (masters and slaves) hosting this zone.
  acl = [
    "10.0.0.0/8",
    "192.168.0.0/16",
    "172.16.0.0/12"
  ]
}
