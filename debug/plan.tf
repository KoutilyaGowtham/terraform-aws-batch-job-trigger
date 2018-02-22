terraform {
    required_version = ">= 0.11.3"
    backend "s3" {}
}

data "terraform_remote_state" "iam" {
    backend = "s3"
    config {
        bucket = "transparent-test-terraform-state"
        key    = "us-west-2/debug/security/iam/terraform.tfstate"
        region = "us-east-1"
    }
}

module "trigger_batch_job" {
    source = "../"

    region                  = "us-west-2"
    project                 = "Debug"
    creator                 = "kurron@jvmguy.com"
    environment             = "development"
    purpose                 = "Triggers Spring Batch jobs via HTTP POST."
    freetext                = "Must coordinate the schedule with the EC2 instances."
    role_arn                = "${data.terraform_remote_state.iam.ec2_park_role_arn}"
    trigger_cron_expression = "cron(1/2 * ? * MON-FRI *)"
    api_key                 = "FAKE KEY"
    endpoint                = "https://government.transparent.engineering/development/slurp-e-archiver/launch"
}
