aws_region       = "eu-north-1"
project_name     = "aws-ha-dr"
environment      = "lab"

ami_id           = "YOUR_AMI_ID"
app_image        = "YOUR_ECR_IMAGE_URI"

instance_type    = "t3.micro"
app_port         = 3001

min_size         = 2
desired_capacity = 2
max_size         = 4

health_check_path = "/"
enable_asg        = false
