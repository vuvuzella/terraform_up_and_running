//  values in the variables can be changed either by
//      1. as an argument to switch -var or -var-file
//      2. Environment Variables TF_VAR_<variable name>
// types: string, number, bool, list(type), map, set, object, tuple, any
variable "webserver_port" {
    default     = 8080 
    description = "port used for the webserver"
    type        = number
} 