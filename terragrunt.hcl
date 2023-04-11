locals {
  endpoints       = yamldecode(file("${get_parent_terragrunt_dir()}/config/dc_endpoints.yml"))
  parent_view     = try(read_terragrunt_config("../../../../view.hcl"), "")
  parent_region   = try(local.parent_view.locals.region, "")
  parent_provider = try(local.parent_view.locals.provider, "")
  view_vars       = read_terragrunt_config(find_in_parent_folders("view.hcl"))
  region          = try(local.view_vars.locals.region,"")
  provider        = try(local.view_vars.locals.provider,"")
}

// Remote state uses default AWS environment vars
// AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket           = "auto-gitops-global-dns-management"
    key              = "${path_relative_to_include()}/terraform.tfstate"
    region           = "us-east-1"
    encrypt          = true
    dynamodb_table   = "auto-gitops-global-dns-management"
    force_path_style = true
  }
}

// Route53 (AWS) provider uses environment vars: R53_ACCESS_KEY_ID/R53_SECRET_ACCESS_KEY
// PowerDNS provider uses environment var: PDNS_API_KEY
generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
provider "route53" {
  alias      = "parent"
  region     = "us-west-2"
  access_key = "${get_env("R53_ACCESS_KEY_ID")}"
  secret_key = "${get_env("R53_SECRET_ACCESS_KEY")}"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}
provider "powerdns" {
  alias      = "parent"
%{if try(local.parent_provider, "NONE") == "powerdns"}
  server_url = "${local.endpoints["${local.parent_region}"]["${local.parent_provider}"]["api"]}"
  api_key    = "${get_env("PDNS_API_KEY")}"
%{else}
  server_url = "${local.endpoints["default"]["powerdns"]["api"]}"
  api_key    = "${get_env("PDNS_API_KEY")}"
%{endif}
}
provider "bind" {
  alias      = "parent"
}
provider "route53" {
  alias      = "local"
  region     = "us-west-2"
  access_key = "${get_env("R53_ACCESS_KEY_ID")}"
  secret_key = "${get_env("R53_SECRET_ACCESS_KEY")}"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}
provider "powerdns" {
  alias      = "local"
%{if try(local.provider, "NONE") == "powerdns"}
  server_url = "${local.endpoints["${local.region}"]["${local.provider}"]["api"]}"
  api_key    = "${get_env("PDNS_API_KEY")}"
%{else}
  server_url = "${local.endpoints["default"]["powerdns"]["api"]}"
  api_key    = "${get_env("PDNS_API_KEY")}"
%{endif}
}
provider "bind" {
  alias      = "local"
}
provider "jinja" {
  strict_undefined = true
}
terraform {
  required_version = "1.3.7"
  required_providers {
    route53 = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
    powerdns = {
      source  = "pan-net/powerdns"
      version = "1.5.0"
    }
    bind = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
    jinja = {
      source = "NikolaLohinski/jinja"
      version = "1.10.0"
    }
  }
}
EOF
}
