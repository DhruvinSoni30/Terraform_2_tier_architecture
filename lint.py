import glob
import re
import os
import hcl

file = glob.glob('terraform.tfvars')
region_validator = re.compile('(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-?(1|2)')
cidr_validator = re.compile('^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$')
db_name_validator = re.compile('^[A-Za-z0-9 ]+$')


for f in file:
    with open(f, 'r') as fp:
        obj = hcl.load(fp)
        errors = []

        if 'region' not in obj:
            errors.append("The variable 'region' not defined")

        region = obj['region']
        if region_validator.search(region) is None:
            errors.append("Invalid Region")

        if 'project_name' not in obj:
            errors.append("Tag is not defined")

        if 'vpc_cidr' not in obj:
            errors.append("CIDR block for VPC not defined")

        if 'public_subnet_az1_cidr' and 'public_subnet_az2_cidr' not in obj:
            errors.append("CIDR block for Public Subnet not defined")

        if 'private_subnet_az1_cidr' and 'private_subnet_az2_cidr' not in obj:
            errors.append("CIDR block for Private Subnet not defined")

        vpc_cidr =  obj['vpc_cidr']
        if cidr_validator.search(vpc_cidr) is None:
            errors.append("Invalid CIDR block for VPC")
        
        public_subnet_az1_cidr = obj['public_subnet_az1_cidr']
        if cidr_validator.search(public_subnet_az1_cidr) is None:
            errors.append("Invalid CIDR block for Public subnet in AZ1")

        public_subnet_az2_cidr = obj['public_subnet_az2_cidr']
        if cidr_validator.search(public_subnet_az2_cidr) is None:
            errors.append("Invalid CIDR block for Public subnet in AZ2")

        private_subnet_az1_cidr = obj['private_subnet_az1_cidr']
        if cidr_validator.search(private_subnet_az1_cidr) is None:
            errors.append("Invalid CIDR block for Private subnet in AZ1")

        private_subnet_az2_cidr = obj['private_subnet_az2_cidr']
        if cidr_validator.search(private_subnet_az2_cidr) is None:
            errors.append("Invalid CIDR block for Private subnet in AZ2")

        if 'instance_type' not in obj:
            errors.append("Instance type is not defned")
        
        if 'ami_id' not in obj:
            errors.append("AMI ID is not defined")

        if 'db_name' not in obj:
            errors.append("DB Name is not defined")

        db_name = obj['db_name']
        if db_name_validator.search(db_name) is None:
            errors.append("Invalid DB name, Special characters are not allowed")

fp.close()

if len(errors) > 0:
    for error in errors:
        print(error)
    exit(1)

else:
    print("All the check passed!")
