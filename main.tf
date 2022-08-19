terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

//variable "reponame" {}
//variable "container_port" {}

provider "aws" {
  region  = "us-east-1"
}


resource "aws_instance" "lab_server_01" {
  image = docker_image.nginx.latest
  name  = eeric466      //var.reponame    Cambiarla dinámicamente por la Variable env.DOCKER_REPO que está en el Jenkins
  ports {
    internal = 80
    external = 82       //var.container_port  // Cambiarla dinámicamente por la variable CONTAINER_PORT que está en el Jenkins.
  }
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
  security_groups = ["launch-wizard-1","default"]
  key_name= "key_serv_pruebas"
  tags = {
    Name = "serv_tf_lab12"
  }
}

output "instance_public_ip" {
  description = "Obtener la IP publica de mi instancia"
  value = aws_instance.lab_server_01.public_ip  // aws_instance.$NOMBRE-RECURSO-TIPO-aws_instance$.public_ip
}
