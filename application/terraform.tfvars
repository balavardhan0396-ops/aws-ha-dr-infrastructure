aws_region       = "eu-north-1"
project_name     = "aws-ha-dr"
environment      = "lab"

ami_id           = "ami-003264f7c6723d2a8"
app_image        = "297681905216.dkr.ecr.eu-north-1.amazonaws.com/aws-ha-dr-lab-app"

instance_type    = "t3.micro"
app_port         = 3001

min_size         = 2
desired_capacity = 2
max_size         = 4

health_check_path = "/"
enable_asg        = false
