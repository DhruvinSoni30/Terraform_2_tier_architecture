#Create EC2 instances in public subnet 1
resource "aws_instance" "demo_instance_1" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id_az1
  security_groups             = [var.security_group]
  availability_zone           = data.aws_availability_zones.az.names[0]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Code finally Worked.EC2 instance launched in us-east-2a!!!</h1>" > var/www/html/index.html
    EOF

  tags = {
    Name = "${var.project_name}-demo-instance-1"
  }
}

#Create EC2 instances in public subnet 2
resource "aws_instance" "demo_instance_2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id_az2
  security_groups             = [var.security_group]
  availability_zone           = data.aws_availability_zones.az.names[1]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Code finally Worked.EC2 instance launched in us-east-2b!!!</h1>" > var/www/html/index.html
    EOF

  tags = {
    Name = "${var.project_name}-demo-instance-1"
  }
}

# AZ
data "aws_availability_zones" "az" {}

# Create a Database instance
resource "aws_db_instance" "db_instance" {
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "projectTerraform"
  password               = "Terraform1234"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = "db_sub_grp"
  vpc_security_group_ids = [var.security_group_db]
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-demo-DB-instance"
  }
}

# create RDS instance subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = [var.subnet_db_1, var.subnet_db_2]
}