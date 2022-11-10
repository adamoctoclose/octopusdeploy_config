terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
    }
  }
}

provider "octopusdeploy" {
  address = var.serverURL
  api_key = var.apiKey
  space_id = var.space

}

resource "octopusdeploy_project_group" "newProjectGroup" {
  name        = var.projectGroupName
  description = var.projectGroupDescription

}

resource "octopusdeploy_environment" "newOctopusEnvironments" {
  count = length(var.environments)
  name  = var.environments[count.index]
}

resource "octopusdeploy_lifecycle" "newLifecycle" {
  name        = "Lifecycle-${var.projectGroupName}"
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
  lifecycle_id     = octopusdeploy_lifecycle.newLifecycle.id
  name             = "Datadog Dashboard - ${var.internalClient}"

}

resource "octopusdeploy_deployment_process" "newDeploymentProcess" {
  project_id = octopusdeploy_project.newProject.id

  step {
    name                = "Plan Terraform Step"
    package_requirement = "LetOctopusDecide"
    condition           = "Success"
    start_trigger       = "StartAfterPrevious"
    action {
      action_type   = "Octopus.TerraformPlan"
      name          = "Plan Terraform Step"
      run_on_server = true
      properties = {
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" : "True",
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" : "False",
        "Octopus.Action.Terraform.GoogleCloudAccount" : "False",
        "Octopus.Action.Terraform.AzureAccount" : "False",
        "Octopus.Action.Terraform.ManagedAccount" : "None",
        "Octopus.Action.Terraform.AllowPluginDownloads" : "True",
        "Octopus.Action.Script.ScriptSource" : "Inline",
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" : "True",
        "Octopus.Action.Terraform.PlanJsonOutput" : "False",
        "Octopus.Action.Terraform.Template" : "terraform {\n  required_providers {\n    octopusdeploy = {\n      source  = \"OctopusDeployLabs/octopusdeploy\"\n    }\n  }\n}",
        "Octopus.Action.Terraform.TemplateParameters" : "{}"
      }

    }
  }

  step {
    name                = "Manual Intervention Required"
    package_requirement = "LetOctopusDecide"
    condition           = "Success"
    start_trigger       = "StartAfterPrevious"
    action {
      action_type   = "Octopus.Manual"
      name          = "Manual Intervention Required"
      run_on_server = true
      properties = {
        "Octopus.Action.Manual.BlockConcurrentDeployments" : "False",
        "Octopus.Action.Manual.Instructions" : "Please approve deployment",
        "Octopus.Action.Manual.ResponsibleTeamIds" : "teams-everyone"
      }
    }
  }


  step {
    name                = "Apply Terraform Step"
    package_requirement = "LetOctopusDecide"
    condition           = "Success"
    start_trigger       = "StartAfterPrevious"
    action {
      action_type   = "Octopus.TerraformApply"
      name          = "Apply Terraform Step"
      run_on_server = true
      properties = {
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" : "True",
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" : "False",
        "Octopus.Action.Terraform.GoogleCloudAccount" : "False",
        "Octopus.Action.Terraform.AzureAccount" : "False",
        "Octopus.Action.Terraform.ManagedAccount" : "None",
        "Octopus.Action.Terraform.AllowPluginDownloads" : "True",
        "Octopus.Action.Script.ScriptSource" : "Inline",
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" : "True",
        "Octopus.Action.Terraform.PlanJsonOutput" : "False",
        "Octopus.Action.Terraform.Template" : "terraform {\n  required_providers {\n    octopusdeploy = {\n      source  = \"OctopusDeployLabs/octopusdeploy\"\n    }\n  }\n}",
        "Octopus.Action.Terraform.TemplateParameters" : "{}"
      }
    }
  }
}

