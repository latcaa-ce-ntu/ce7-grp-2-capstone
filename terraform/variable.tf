variable "name_prefix" {
  description = "Prefix to be added to resource names"
  type        = string
  default     = "ce7-grp-2"
}
# variable "ecs_cluster_name" {
#   description = "ECS Cluster Name"
#   type        = string
#   default     = "azmi1ECSCluster"
# }

# variable "ecs_task_def_family" {
#   description = "ECS Task Definition Family Name"
#   type        = string
#   default     = "azmi1TaskDefinitionTest"
# }

# variable "sg_name" {
#   description = "Security Group Name"
#   type        = string
#   default     = "azmi1-tf-sg-allow-ssh-http-https"
# }

# variable "ecs_service_name" {
#   description = "ECS Service Name"
#   type        = string
#   default     = "azmi1-nginx-service"
# }

# variable "alb_name" {
#   description = "Application Load Balancer Name"
#   type        = string
#   default     = "azmi1-nginx-alb"
# }

# variable "alb_tg_name" {
#   description = "Application Load Balancer Target Group Name"
#   type        = string
#   default     = "azmi1-nginx-tg"
# }

# variable "container_name" {
#   description = "Container Name"
#   type        = string
#   default     = "azmi1-nginx-container"
# }

# variable "key_name" {
#   description = "Name of EC2 Key Pair"
#   type        = string
#   default     = "azmi1-keypair-useast1-1" # Replace with your own key pair name (without .pem extension) that you have downloaded from AWS console previously
# }

# variable "ec2_name" {
#   description = "Name of EC2"
#   type        = string
#   default     = "azmi1-ec2-tf-cicd" # Replace with your preferred EC2 Instance Name 
# }

# variable "instance_type" {
#   description = "EC2 Instance type"
#   type        = string
#   default     = "t2.micro"
# }