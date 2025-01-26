resource "humanitec_resource_definition" "redis_in_cluster" {
  id          = "${var.prefix}redis"
  name        = "${var.prefix}redis"
  type        = "redis"
  driver_type = "humanitec/template"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = file("${path.module}/manifests/redis/init.gtpl")
        manifests = file("${path.module}/manifests/redis/manifests.gtpl")
        outputs   = file("${path.module}/manifests/redis/outputs.gtpl")
        secrets   = file("${path.module}/manifests/redis/secrets-outputs.gtpl")
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "redis_in_cluster" {
  resource_definition_id = humanitec_resource_definition.redis_in_cluster.id
  force_delete           = true
}