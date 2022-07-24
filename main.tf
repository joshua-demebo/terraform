locals {
  ami_id           = "ami-052efd3df9dad4825"
  vpc_id           = "vpc-0f899a2630c0d27b3"
  ssh_user         = "ubuntu"
  key_name         = "ec2-keypair"
  private_key_path = "/home/labsuser/remoteexec/ec2-keypair.pem"
}

provider "aws" {
  access_key = "ASIAYX46KLMEC4GHLOZI"
  secret_key = "GpHADW1hVzR6TUFCmOKrMRrNjB4eLOb71QcOUXyP"
  token      = "FwoGZXIvYXdzEEIaDB1hQSdEf54L3UDc/iK4ASz3jEhFGeA2J+Ka9W17MYiquw9EEC6lc9wRTLr3sGCX0+Y8T/ZkN+fC43eyVfw8l2KP2pdSeONHTKjCB9HS5tJcsAKEt0kysOlZBQoyI6nlH2jDfV973K2eml1IM8LyCv8vpdMvSZkEw+m6LCEoOkYNA0hDMAWlOkNcNI0/XK2GHQD8Y/LFGXCFOcFWgnZ8RJAe3gT/tGLa0grLpUSeT5f00B9Gvn9tWin0yhpKqO12adsZ7NHHuXMoorzwlgYyLSMul0HefrbGK2xdJ4thIbK49jswe9C/3LvpT/YQP8hZdAms7emfmhL1/2ZU0w=="
  region     = "us-east-1"
}

resource "aws_security_group" "demoaccess" {
  name   = "demoaccess"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = local.ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.demoaccess.id]
  key_name                    = local.key_name

  tags = {
    Name = "Demo test"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = local.ssh_user
    private_key = file(local.private_key_path)
    timeout     = "4m"
  }

  provisioner "remote-exec" {
    inline = [
      "touch /home/ubuntu/demo-file-from-terraform.txt"
    ]
  }
}
