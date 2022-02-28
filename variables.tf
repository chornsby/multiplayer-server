variable "fingerprint" {
  description = "The API Key fingerprint obtained from Oracle Cloud"
  type        = string
}

variable "game_server_name" {
  description = "The human-readable name for the game and server"
  type        = string
}

variable "game_server_password" {
  description = "The password used by players to access the game"
  sensitive   = true
  type        = string
}

variable "open_ports" {
  description = "The ports to open for incoming game server connections"
  type        = set(number)
}

variable "oracle_private_key_path" {
  description = "The API Key private key path obtained from Oracle Cloud"
  type        = string
}

variable "region" {
  description = "The Oracle Cloud region to deploy the server"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Your own SSH public key used to access the server"
  type        = string
}

variable "tenancy_ocid" {
  description = "The API Key tenancy id from obtained from Oracle Cloud"
  type        = string
}

variable "user_ocid" {
  description = "The API Key user id obtained from Oracle Cloud"
  type        = string
}
