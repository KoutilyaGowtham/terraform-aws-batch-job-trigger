variable "region" {
    type = "string"
    description = "The AWS region to deploy into (e.g. us-east-1)"
}

variable "project" {
    type = "string"
    description = "Name of the project these resources are being created for"
}

variable "purpose" {
    type = "string"
    description = "Role the resource will play in the system"
}

variable "creator" {
    type = "string"
    description = "Person creating the resources"
}

variable "environment" {
    type = "string"
    description = "Context the resources will be used in, e.g. production"
}

variable "freetext" {
    type = "string"
    description = "Information that does not fit in the other tags"
}

variable "trigger_cron_expression" {
    type = "string"
    description = "Cron expression describing when the trigger should be fired"
}

variable "role_arn" {
    type = "string"
    description = "ARN of the role that has rights to make HTTP calls"
}

variable "api_key" {
    type = "string"
    description = "API Key to specify in the x-api-key header"
}

variable "endpoint" {
    type = "string"
    description = "URL to POST to, triggering the batch job"
}
