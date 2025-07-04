variable "public" {
  type = map(any)
  default = {
    us-west-1a = "10.0.10.0/24"
    us-west-1c = "10.0.20.0/24"
  }
}
variable "private" {
  type = map(any)
  default = {
    us-west-1a = "10.0.100.0/24"
    us-west-1c = "10.0.200.0/24"
  }
}
variable "AZ" {
  type    = list(any)
  default = ["us-west-1a", "us-west-1c"]
}
variable "ports" {
  type    = map(any)
  default = { http = "80", https = "443", ssh = "22" }
}
variable "ports_ALB" {
  type    = map(any)
  default = { http = "80", https = "443" }
}






