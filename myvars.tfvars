availability_zone = [{"us-east-1a"}, {"us-east-1b"}]
vpc_id =  aws.vpc.alts_school_project.vpc.id   
key_name = "newkey-e1.pem"
aws_security_group_ids = [alt_school_project_sg]