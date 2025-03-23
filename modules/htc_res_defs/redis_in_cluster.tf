resource "humanitec_resource_definition" "redis_in_cluster" {
  id          = "${var.prefix}redis"
  name        = "${var.prefix}redis"
  type        = "redis"
  driver_type = "humanitec/template"

  driver_inputs = {
    values_string = jsonencode(yamldecode(file("${path.module}/manifests/redis/definition-values.yaml")))
  }
}

resource "humanitec_resource_definition_criteria" "redis_in_cluster" {
  resource_definition_id = humanitec_resource_definition.redis_in_cluster.id
  force_delete           = true
}