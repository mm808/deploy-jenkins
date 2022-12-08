variable "env" {
  type    = string
}

variable "app_name" {
  description = "app_name"
  type = string  
}

variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "lb_subnet_ids" {
  description = "load balancer subnet"
  type = list(string)
}

variable "lb_subnet_cidrs" {
  description = "load balancer cidr ranges"
  type = list(string)
}

variable "jenkins-ec2-id" {
  description = "jenkins-ec2-id from output"
  type = string
}

variable "webserver-port" {
  type    = number
  default = 8080
}
