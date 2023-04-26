# configure aws provider
provider "aws" {
  region  = var.region
  profile = "dhsoni"
}

# create VPC
module "vpc" {

  source                  = "../modules/vpc"
  region                  = var.region
  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  public_subnet_az1_cidr  = var.public_subnet_az1_cidr
  public_subnet_az2_cidr  = var.public_subnet_az2_cidr
  private_subnet_az1_cidr = var.private_subnet_az1_cidr
  private_subnet_az2_cidr = var.private_subnet_az2_cidr
}


# create Security Group
module "security_group" {

  source = "../modules/security-groups"
  vpc_id = module.vpc.vpc_id

}

# create ALB
module "alb" {

  source               = "../modules/alb"
  project_name         = var.project_name
  alb_security_group   = module.security_group.alb_security_group_id
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id
  vpc_id               = module.vpc.vpc_id
  instance_1           = module.ec2.instance_1_id
  instance_2           = module.ec2.instance_2_id
}

# create EC2

module "ec2" {
  source            = "../modules/ec2"
  project_name      = var.project_name
  security_group_db = module.security_group.db_security_group_id
  subnet_id_az1     = module.vpc.public_subnet_az1_id
  subnet_id_az2     = module.vpc.public_subnet_az2_id
  security_group    = module.security_group.public_ec2_security_group_id
  db_name           = var.db_name
  subnet_db_1       = module.vpc.private_subnet_az1_id
  subnet_db_2       = module.vpc.private_subnet_az2_id
  instance_type     = var.instance_type
  ami_id            = var.ami_id
}




