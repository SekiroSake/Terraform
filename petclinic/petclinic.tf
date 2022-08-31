provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "petclinic_terraform"
  location = "East US"
}

resource "azurerm_spring_cloud_service" "example" {
  name                = "petclinic_terraform_example_springapps"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  config_server_git_setting {
    uri          = "https://github.com/azure-samples/spring-petclinic-microservices-config"
    label        = "master"
    search_paths = ["."]
  }
}

resource "azurerm_spring_cloud_app" "example" {
  name                = "petclinic_terraform_example_springapps"
  resource_group_name = azurerm_resource_group.example.name
  service_name        = azurerm_spring_cloud_service.example.name
  is_public           = true
  https_only          = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_spring_cloud_java_deployment" "example" {
  name                = "default"
  spring_cloud_app_id = azurerm_spring_cloud_app.example.id
  instance_count      = 2
  jvm_options         = "-XX:+PrintGC"
  runtime_version     = "Java_11"

  environment_variables = {
    "Env" : "Staging"
  }
}

resource "azurerm_spring_cloud_active_deployment" "example" {
  spring_cloud_app_id = azurerm_spring_cloud_app.example.id
  deployment_name     = azurerm_spring_cloud_java_deployment.example.name
}