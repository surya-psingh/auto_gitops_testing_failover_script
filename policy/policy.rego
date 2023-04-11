package terraform

import input.tfplan as tfplan

deny[msg] {
   resource := input.resource_changes[_]
   dns_record := resource.change.after
   action := resource.change.actions[i]
   not action == "no-op"
   dns_record.type == "MX"
   msg := sprintf("MX records changing denied by policy (record type after apply: MX) for record %s whith value %s", [ dns_record.name, dns_record.records ])
}

deny[msg] {
   resource := input.resource_changes[_]
   dns_record := resource.change.before
   action := resource.change.actions[i]
   not action == "no-op"
   dns_record.type == "MX"
   msg := sprintf("MX records changing denied by policy (record type before apply: MX) for record %s with value %s", [ dns_record.name, dns_record.records ])
}

deny[msg] {
   resource := input.resource_changes[_]
   dns_record := resource.change.after
   dns_record.type == "SOA"
   action := resource.change.actions[i]
   not action == "no-op"
   msg := sprintf("SOA records changing denied by policy (record type after apply: SOA) for record %s with value %s", [ dns_record.name, dns_record.records ])
}

deny[msg] {
   resource := input.resource_changes[_]
   dns_record := resource.change.before
   dns_record.type == "SOA"
   action := resource.change.actions[i]
   not action == "no-op"
   msg := sprintf("SOA records changing denied by policy (record type before apply: SOA) for record %s with value %s", [ dns_record.name, dns_record.records ])
}
