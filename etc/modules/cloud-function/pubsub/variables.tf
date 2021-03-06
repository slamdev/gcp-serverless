variable "bucket" {
  type = string
}

variable "regions" {
  type = set(string)
}

variable "name" {
  type = string
}

variable "files" {
  type = set(string)
}

variable "available_memory_mb" {
  type    = number
  default = 128
}

variable "entry_point" {
  type    = string
  default = "Trigger"
}

variable "timeout_seconds" {
  type    = number
  default = 60
}

variable "service_account_email" {
  type    = string
  default = null
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "vpc_connector" {
  type    = string
  default = null
}

variable "max_instances" {
  type    = number
  default = null
}

variable "topic_trigger" {
  type = string
}
