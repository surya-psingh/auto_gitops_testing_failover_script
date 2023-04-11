locals {
  // Name of this view
  name     = "global"

  // View type (i.e. "operational" or "template")
  // The "operational" mode causes the view to be created/rendered.
  // The "template" state is reserved for template views intended to be inherited by other views
  type     = "operational"

  // Location (cloud region or on-premise data center) where this view should be hosted.
  // For on-premise data center regions, these should be defined in dc_regions.yml.  For
  // "out-of-tree" zones, this setting is ignored.
  region   = "vo-sv2"

  // The provider/stack where this view should be created/rendered.  For "out-of-tree"
  // or "template" zones, this provider should be set to "none".
  provider = "route53"
}
