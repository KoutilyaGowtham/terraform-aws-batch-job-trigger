terraform {
    required_version = ">= 0.11.3"
    backend "s3" {}
}

provider "aws" {
    region     = "${var.region}"
}

resource "random_pet" "pet" {
}

resource "template_dir" "trigger_job" {
    source_dir       = "${path.module}/files"
    destination_dir  = "${path.module}/python-packages"
    vars {
        api_key = "${var.api_key}"
        endpoint = "${var.endpoint}"
    }
}

resource "null_resource" "python_packages" {
    triggers = {
        run_every_time = "${timestamp()}"
    }

    provisioner "local-exec" {
        command = "pip install requests -t ${path.module}/python-packages"
    }
}

data "archive_file" "trigger_job" {
    type        = "zip"
    output_path = "${path.module}/archives/trigger-job.zip"
    source_dir  = "${path.module}/python-packages"
    depends_on  = ["null_resource.python_packages"]
}

resource "aws_lambda_function" "trigger_job" {
    filename         = "${path.module}/archives/trigger-job.zip"
    function_name    = "trigger-batch-job-${random_pet.pet.id}"
    handler          = "trigger-batch-job.lambda_handler"
    role             = "${var.role_arn}"
    description      = "${var.purpose}"
    runtime          = "python3.6"
    source_code_hash = "${data.archive_file.trigger_job.output_base64sha256}"
    tags {
        Name        = "Trigger Job"
        Project     = "${var.project}"
        Purpose     = "${var.purpose}"
        Creator     = "${var.creator}"
        Environment = "${var.environment}"
        Freetext    = "${var.freetext}"
    }
}

resource "aws_cloudwatch_event_rule" "trigger_job" {
    name                = "trigger-batch-${random_pet.pet.id}"
    schedule_expression = "${var.trigger_cron_expression}"
    description         = "${var.purpose}"
    is_enabled          = true
}

resource "aws_cloudwatch_event_target" "trigger_job" {
    rule = "${aws_cloudwatch_event_rule.trigger_job.name}"
    arn  = "${aws_lambda_function.trigger_job.arn}"
}

resource "aws_lambda_permission" "trigger_job" {
      action         = "lambda:InvokeFunction"
      function_name  = "${aws_lambda_function.trigger_job.function_name}"
      principal      = "events.amazonaws.com"
      statement_id   = "AllowExecutionFromCloudWatch"
      source_arn     = "${aws_cloudwatch_event_rule.trigger_job.arn}"
}
