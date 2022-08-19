terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region  = "us-east-1"
}


resource "aws_instance" "lab_server_01" {
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
  security_groups = ["launch-wizard-1","default"]
  key_name= "key_serv_pruebas"
  tags = {
    Name = "serv_tf_lab17"
  }
}

output "instance_public_ip" {
  description = "Obtener la IP publica de mi instancia"
  value = aws_instance.lab_server_01.public_ip  // aws_instance.$NOMBRE-RECURSO-TIPO-aws_instance$.public_ip
}
