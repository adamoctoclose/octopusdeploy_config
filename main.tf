terraform {
  required_providers {
    octopusdeploy = {
      source  = "OctopusDeployLabs/octopusdeploy"
    }
  }
}

provider "octopusdeploy" {
  address       = var.serverURL
  api_key       = var.apiKey

}

resource "octopusdeploy_project_group" "newProjectGroup" {
    name = var.projectGroupName
    description = var.projectGroupDescription
  
}

resource "octopusdeploy_environment" "newOctopusEnvironments" {
    count = length(var.environments)
    name = var.environments[count.index]
}

resource "octopusdeploy_lifecycle" "newLifecycle" {
  name = "Lifecycle-${var.projectGroupName}"
  description = "Lifecycles for ${var.projectGroupName}"

    release_retention_policy {
    quantity_to_keep    = 1
    should_keep_forever = true
    unit                = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep    = 30
    should_keep_forever = false
    unit                = "Items"
  }

}

resource "octopusdeploy_project" "newProject" {

    project_group_id = octopusdeploy_project_group.newProjectGroup.id
    lifecycle_id = octopusdeploy_lifecycle.newLifecycle.id
    name = "Datadog Dashboard - ${var.internalClient}"
  
}

resource "octopusdeploy_deployment_process" "newDeploymentProcess" {
  project_id = octopusdeploy_project.newProject.id

  step {
    
  }
}
