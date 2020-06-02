
variable "client_id" {
  description = "Application ID of SP User"
}

variable "client_secret" {
  description = "Secret of SP User"
}

variable "tenant_id" {
  description = "Directory/Tenant ID of SP User"
}
variable "subscription_id" {
  description = "Subscription ID of SP User"
}

variable "vnets" {
  type = map
  default = {
   "HUB" = "10.10.0.0/16"
   "Spoke1" = "10.20.0.0/16"
   "Spoke2" = "10.30.0.0/16"
  }
}

variable "rg1" {
  description = "Resource Group 1"
}

variable "rg1_location" {
  description = "Resource Group 1 location"
}

variable "gw_subnet" {
  description = "GatewaySubnet"
}
variable "localgw_name" {
  description = "Name of the Local Gateway"
}
variable "public_ip" {
  description = "Public IP of the Local Gateway"
}
variable "vpn_network" {
  description = "Private Network behind Local Gateway"
  default = ["172.23.0.0/16"]
}

variable "psk" {
  description = "PSK for IPSec VPN"
}