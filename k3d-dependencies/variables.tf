variable "databases" {
  default = []
}

variable "environments" {
  default = ["development", "staging", "production"]
}

variable "acme_email_address" {
  default = "shaw@immortal.net.au"
}