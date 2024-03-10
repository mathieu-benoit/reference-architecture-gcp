resource "humanitec_resource_definition" "agent" {
  id          = "${var.prefix}agent"
  name        = "${var.prefix}agent"
  type        = "agent"
  driver_type = "humanitec/agent"
  driver_inputs = {
    values_string = jsonencode({
      id = "${var.prefix}agent"
    })
  }
}

resource "humanitec_resource_definition_criteria" "agent" {
  resource_definition_id = humanitec_resource_definition.agent.id
  env_id                 = var.environment
  env_type               = var.environment_type
}

resource "humanitec_agent" "agent" {
  id          = "${var.prefix}agent"
  description = "${var.prefix}agent"
  public_keys = [
    {
      key = var.agent_public_key
    }
  ]
}