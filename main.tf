terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "my-first-server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld!"
  }
}

resource "aws_instance" "python_app_instance" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name      = "key-0394ad6df7a5ea8f2"
  
  tags = {
    Name = "HelloWorld!"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/your-key.pem")
    host        = aws_instance.my-first-server.public_ip
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "app.py"
    destination = "/home/ec2-user/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install python3 -y",
      "sudo pip3 install pyspark",
      "python3 /home/ec2-user/app.py"
    ]
  }
}

resource "aws_emr_cluster" "spark_cluster" {
  name = var.cluster_name
  release_label = var.release_label 
  applications = var.applications
  
  ec2_attributes {
    subnet_id = var.subnet_id
    instance_profile = var.instance_profile
    emr_managed_master_security_group = var.emr_managed_master_security_group
    emr_managed_slave_security_group  = var.emr_managed_slave_security_group
    key_name = var.key_name
  }

  service_role = var.service_role
  autoscaling_role = var.autoscaling_role

  master_instance_group {
    instance_type = var.master_instance_type
    instance_count = var.master_instance_count
  }

  core_instance_group {
    instance_type = var.core_instance_type
    instance_count = var.core_instance_count
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Security group for my application"

  vpc_id = "vpc-0f62caa1158f14445"

  // Regles entrantes
  // Par exemple, permettre le trafic SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Regles sortantes
  // Par exemple, permettre tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create the MongoDB Cluster with Document DB
  resource "aws_docdb_cluster" "docdb" {
    cluster_identifier = var.cluster_identifier
    engine = "docdb"
    engine_version = var.engine_version
    master_username = var.master_username
    master_password = var.master_password
    enabled_cloudwatch_logs_exports = ["audit", "profiler"]
}

#Create Instances in the previous Cluster 
resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class
  engine             = "docdb"
}
# suite activite 1 deployer un cluster Apache / spark = 2 machines mini pour la hte dispo (load balancing)
# sur aws = serverless documentDB
# conseil : spliter le main.tf pour cacher le access key
# lancer EMR + ECS + EC2
