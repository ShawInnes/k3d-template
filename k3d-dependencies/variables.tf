variable "databases" {
  default = ["unleash"]
}

variable "environments" {
  default = ["development", "test", "production"]
}

variable "install_unleash" {
  default = false
  type = bool
}
