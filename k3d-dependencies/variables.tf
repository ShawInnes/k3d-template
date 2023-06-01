variable "databases" {
  default = ["unleash"]
}

variable "environments" {
  default = ["development", "test", "production"]
}

variable "install_unleash" {
  default = true
  type = bool
}
